#! /usr/bin/env nextflow

println "I want to BLAST $params.query to $params.dbDir/$params.dbName using $params.threads CPUs and output it to $params.outdir"

process runBlast {

  script:
  """
  blastn  -num_threads 2 -db $PWD/DB/blastDB -query $PWD/input.fasta -outfmt 6 -out input.blastout
  """

}
