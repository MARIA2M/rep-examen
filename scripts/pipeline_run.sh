
# conda install -y seqtk
# conda install -y fastqc
# conda install -y cutadapt
# conda install -y star
# conda install -y multiqc

export WD=$(pwd)

echo $WD


mkdir  -p res/genome
wget -O res/genome/ecoli.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
gunzip -k res/genome/ecoli.fasta.gz

mkdir -p res/genome/star_index
STAR --runThreadN 4 --runMode genomeGenerate \
--genomeDir res/genome/star_index/ \
--genomeFastaFiles res/genome/ecoli.fasta \
--genomeSAindexNbases 9

mkdir  -p data/originales
mv data/*.fastq.gz data/originales/
for i in $(ls data/originales/*.fastq.gz | cut -d "_" -f1 | sed 's:data/originales/::' | sort | uniq)
do
    seqtk sample -s100 data/originales/${i}_1.fastq.gz 3000 | gzip > data/${i}_1.fastq.gz
    seqtk sample -s100 data/originales/${i}_2.fastq.gz 3000 | gzip > data/${i}_2.fastq.gz

    echo ${i}_1.fastq.gz
    echo 'Número de líneas del Fastq:' `gunzip -c data/${i}_1.fastq.gz | grep "^+$" | wc -l`
    echo ${i}_2.fastq.gz
    echo 'Número de líneas del Fastq:' `gunzip -c data/${i}_2.fastq.gz | grep "^+$" | wc -l`

    echo ${i}_1.fastq.gz
    echo 'Número de líneas del Fastq originales:' `gunzip -c data/originales/${i}_1.fastq.gz | grep "^+$" | wc -l`
    echo ${i}_2.fastq.gz
    echo 'Número de líneas del Fastq originales:' `gunzip -c data/originales/${i}_2.fastq.gz | grep "^+$" | wc -l`

    bash scripts/analyse_sample.sh $i
done

multiqc -o out/multiqc $WD
