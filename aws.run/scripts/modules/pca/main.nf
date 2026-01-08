#!/usr/bin/env nextflow

process CREATE_PCA {
    label 'pca'

    publishDir "$params.results/pca", mode: 'copy', overwrite: true
    memory '6 GB'

    input:
      path fcount
      path fpanel   

    output:
      path "*.svg"
      path "*.html"
      path "output.txt"

    script:
    """
      #!/usr/bin/env python3

      from sklearn.decomposition import PCA
      import plotly.express as px
      import pandas
      import sys
      import traceback


      try:
          input_count = "${fcount}"
          input_panel = "${fpanel}"
          clr = "rgb(0, 0, 112)"  # Define color for PCA plot

          # Load into pandas
          df = pandas.read_csv(input_count)
          duplicates = df[df.duplicated(subset=['sample', 'variant'], keep=False)]
          if not duplicates.empty:
              print("Warning: Duplicate entries found:", file=sys.stderr)
              print(duplicates, file=sys.stderr)

          # Pivot to sample as index and variants as columns
          pca_df = df.pivot_table(index='sample', columns='variant', values='counter', aggfunc='sum').fillna(0)

          # Check data before PCA (to debug the warning)
          print("PCA input shape:", pca_df.shape)
          print("PCA input head:", pca_df.head())
          print("Any NaN in PCA input?", pca_df.isna().any().any())

          # Apply PCA (Principal Component Analysis)
          pca = PCA(n_components=2)
          pca_result = pca.fit_transform(pca_df)
          pca_df = pandas.DataFrame(pca_result, index=pca_df.index, columns = ['PC1', 'PC2'])

          # PCA plot
          fig = px.scatter(pca_df, x='PC1', y='PC2', title="PCA", color_discrete_sequence=[clr])
          fig.update_layout(  height=800, width=800,
              xaxis=dict(range=[-40, 40], showgrid=False, zeroline=False),
              yaxis=dict(range=[-40, 40], showgrid=False, zeroline=False) )
          fig.write_image("pca_plot.svg")
          fig.write_html("pca_plot.html")  


          # Read panel information file
          panel_df = pandas.read_csv(input_panel, sep='\\t')
          pca_df = pca_df.reset_index()
          plot_df = pca_df.merge( panel_df[['sample', 'pop', 'super_pop']], on='sample', how='left' )

          # PCA with population info plot
          fig = px.scatter(plot_df,  x='PC1', y='PC2', title="PCA with Super Population Info", color='super_pop')
          fig.update_layout(  height=800, width=800,
              xaxis=dict(range=[-30, 30], showgrid=False, zeroline=False),
              yaxis=dict(range=[-30, 30], showgrid=False, zeroline=False) )
          fig.write_image("pca_pop_plot.svg")
          fig.write_html("pca_pop_plot.html")

          # Write output file for debugging
          with open("output.txt", "w") as f:
              f.write("PCA completed successfully\\n")

      except Exception as e:
          print("Error:", str(e), file=sys.stderr)
          print(traceback.format_exc(), file=sys.stderr)
          sys.exit(1)


    """
}




