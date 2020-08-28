#! /usr/bin/env nextflow

println "\nI want to BLAST $params.query to $params.dbDir/$params.dbName using $params.threads CPUs and output it to $params.outdir\n"


process runBlast {

  script:
  """
  $params.app -num_threads $params.threads -db $params.dbDir/$params.dbName -query $params.query -outfmt $params.outfmt $params.options -out $params.outFileName
  """
 
}
