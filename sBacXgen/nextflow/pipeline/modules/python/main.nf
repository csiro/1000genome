
process parseProteinAnalyze {

    input:
        path script from './parseProteinAnalyze.py'
        path psortb_output
        path tmhmm_output
        path spaan_output
        path core_genes_hash_json

    
    output:
	path core_genes_update.json", emit: updated_core_genes_hash
   
   shell:
    '''
    export entryDir=$(pwd)
    echo "--- Running !{task.process} !{params.runid} ---"
    echo "----- List working directory"
    pwd ; ls -aFlh
    echo "----- Processing extractCoreGenes  with $(python --version)"
    python3 !{script} 
    
    echo "----- Generating md5sums"
    find . -type f | parallel --will-cite -j+0 'md5sum {} ' | tee --append !{params.runid}_!{task.process}.md5sum
    echo "--- End !{task.process} !{params.runid} ---"
    cp ${entryDir}/.command.out ${entryDir}/!{params.runid}_!{task.process}.log
    '''
}




process extractCoreGenes {
    label 'scripts'
    publishDir "$params.results/scripts", mode: 'copy', overwrite: true

    input:
        path from_roary
        val num_gff

    output:
        path 'core_genes_proteins.faa', emit: core_genes_faa

    script:
    """
    #!/usr/bin/env python3

    import os
    import csv
    import argparse
    from Bio import SeqIO
    from Bio.Seq import Seq


    # Step 3: extract core gene from roary output
    # Load pan_genome_reference.fa into a hash table
    def load_pan_genome_reference(pan_genome_reference_file):
        pan_genome_sequences = {}
        with open(pan_genome_reference_file, "r") as handle:
            for record in SeqIO.parse(handle, "fasta"):
                pan_genome_sequences[record.id] = str(record.seq)
        return pan_genome_sequences

    # Extract core genes' protein sequences
    def extract_core_genes_from_roary(roary_output_folder, gff_folder, output_file):
        gene_presence_absence_file = os.path.join(roary_output_folder, "gene_presence_absence.csv")
        pan_genome_reference_file = os.path.join(roary_output_folder, "pan_genome_reference.fa")
        pan_genome_sequences = load_pan_genome_reference(pan_genome_reference_file)

        # Get the total number of input genomes
        num_genomes = len([f for f in os.listdir(gff_folder) if f.endswith(".gff")])

        core_gene_sequences = []  # List to store protein sequences for fasta output
        
        # Read the gene_presence_absence.csv file
        with open(gene_presence_absence_file, 'r') as csvfile:
            reader = csv.reader(csvfile, delimiter=',')
            header = next(reader)  # Skip the header
            
            for row in reader:
                # Remove double quotes
                row = [col.replace('"', '') for col in row]
                
                num_present = int(row[3])  # Fourth column indicates the number of strains containing this gene
                presence_ratio = num_present / num_genomes
                
                # Select core genes, ratio >= 99%
                if presence_ratio >= 0.99:
                    gene_name = row[0]  # First column is the gene name
                    gene_annotation = row[2]  # Third column is the gene annotation
                    # Find the first non-empty content starting from the fifteenth column
                    gene_id = None
                    for i in range(14, len(row)):
                        if row[i]:  # Non-empty
                            gene_id = row[i]
                            break
                    
                    if gene_id is None:
                        raise ValueError(f"Error: Gene ID {gene_name} not found in gene_presence_absence.csv.")
                        continue  # If no gene_id found, skip to the next row

                    # Check if gene_id is in pan_genome_sequences
                    if gene_id not in pan_genome_sequences:
                        raise ValueError(f"Error: Gene ID {gene_id} not found in pan_genome_reference.fa.")
                    
                    # Find the DNA sequence of the gene from pan_genome_reference.fa
                    dna_seq = pan_genome_sequences[gene_id]
                    protein_seq = str(Seq(dna_seq).translate())  # Translate to protein sequence
                    
                    # Prepare protein sequence for output
                    core_gene_sequences.append(f">{gene_id} [{gene_annotation}]\n{protein_seq}\n")

        # Write all protein sequences to a single fasta file
        with open(output_file, "w") as faa_file:
            faa_file.writelines(core_gene_sequences)
        return 0

    # Main function to handle command-line input and processing
    def main():
        roary_output = "${from_roary}"
        num_genomes = ${num_gff}
        output_file = "core_genes_proteins.faa"

        # Extract core gene sequences
        extract_core_genes_from_roary(roary_output, num_genomes, output_file)

    if __name__ == "__main__":
         main()


    """

}

