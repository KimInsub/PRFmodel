docker run --rm -it  \
      -v $2:/flywheel/v0/input \
      -v $2:/flywheel/v0/output \
      garikoitz/prfanalyze-vista:$1 $3 
