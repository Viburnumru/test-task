# test-task

Docker контейнер позволяет осуществить установку программ: 
## Установленные программы:
- samtools 1.16.1
- htslib 1.16
- bcftools 1.16
- vcftools 0.1.16

## Сборка Docker-образа
```bash
docker build -t test-task .
docker run -it test-task
```
