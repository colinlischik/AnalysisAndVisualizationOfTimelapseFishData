# This script compares fluorophores regarding codon optimization
library(seqinr)
library(data.table)
library(readr)
library(condformat)
library(ggplot2)
library(ggrepel)

#------------------change these variables------------------------------

## set the working directory
setwd("C:\\Users\\Colin_Lischik\\R\\")
## what is the name of the fasta file?
filename = "sequences.fasta"
## set what should be plotted and labeled
### plot1 plots all except the set parameters and labels only the chosen sequences
plot1_noplot = c("SceGFP", "OleGFP", "Kaede")
plot1_label = c("mRuby2", "eGFP", "mCherry")
### plot2 plots only the chosen sequences
plot2_plot = c("SceGFP", "eGFP", "OleGFP")
### plot3 plots all sequences with all labels
plot3_noplot = c("Kaede")

#------------------do not change anything from here on-----------------

##l oading data:
sequences <- read.fasta(file = filename)

## codon usage tables from https://hive.biochemistry.gwu.edu/dna.cgi?cmd=refseq_processor&id=561845
codon_human = read_csv("codon_human.txt", col_names = FALSE)
codon_medaka = read_csv("codon_medaka.txt", col_names = FALSE)
codon_mouse = read_csv("codon_mouse.txt", col_names = FALSE)

## prepare data frame
data(caitab)
aa = c("K", "N", "K", "N", "T", "T", "T", "T", "R", "S", "R", "S", "I", "I", "M", "I", "Q", "H", "Q", "H", "P", "P", "P", "P", "R", "R", "R", "R", "L", "L", "L", "L", "E", "D", "E", "D", "A", "A", "A", "A", "G", "G", "G", "G", "V", "V", "V", "V", "*", "Y", "*", "Y", "S", "S", "S", "S", "*", "C", "W", "C", "L", "F", "L", "F")
codon_all =  data.frame(codon = rownames(caitab), aa, Hs = numeric(64), Ol = numeric(64), Mm = numeric(64))

### prepare df for Hs
for (i in 1:16) {
  starts = gregexpr(pattern = '[GATC]{3}', codon_human$X1[i])
  stops = gregexpr(pattern = "\\(", codon_human$X1[i])
  for (j in 1:4) {
    temp = substr(codon_human$X1[i], starts[[1]][j], stops[[1]][j] - 2)
    codontemp = substr(temp, 1, 3)
    valuetemp = substr(temp, gregexpr("[0-9]", temp)[[1]][1], nchar(temp))
    codon_all$Hs[codon_all$codon == tolower(codontemp)] = as.double(valuetemp)
  }
}
Hs_sum = aggregate(codon_all$Hs, by = list(aa), sum)
colnames(Hs_sum) = c("aa", "Hs_sum")
codon_all = merge(codon_all, Hs_sum, by = "aa")
codon_all$Hs_fraction = codon_all$Hs / codon_all$Hs_sum
Hs_max = aggregate(codon_all$Hs_fraction, by = list(codon_all$aa), max)
colnames(Hs_max) = c("aa", "Hs_fraction_max")
codon_all = merge(codon_all, Hs_max, by = "aa")
codon_all$Hs_relative = codon_all$Hs_fraction / codon_all$Hs_fraction_max


### prepare df for Ol
for (i in 1:16) {
  starts = gregexpr(pattern = '[GATC]{3}', codon_medaka$X1[i])
  stops = gregexpr(pattern = "\\(", codon_medaka$X1[i])
  for (j in 1:4) {
    temp = substr(codon_medaka$X1[i], starts[[1]][j], stops[[1]][j] - 2)
    codontemp = substr(temp, 1, 3)
    valuetemp = substr(temp, gregexpr("[0-9]", temp)[[1]][1], nchar(temp))
    codon_all$Ol[codon_all$codon == tolower(codontemp)] = as.double(valuetemp)
  }
}
Ol_sum = aggregate(codon_all$Ol, by = list(aa), sum)
colnames(Ol_sum) = c("aa", "Ol_sum")
codon_all = merge(codon_all, Ol_sum, by = "aa")
codon_all$Ol_fraction = codon_all$Ol / codon_all$Ol_sum
Ol_max = aggregate(codon_all$Ol_fraction, by = list(codon_all$aa), max)
colnames(Ol_max) = c("aa", "Ol_fraction_max")
codon_all = merge(codon_all, Ol_max, by = "aa")
codon_all$Ol_relative = codon_all$Ol_fraction / codon_all$Ol_fraction_max

### prepare df for Mm
for (i in 1:16) {
  starts = gregexpr(pattern = '[GATC]{3}', codon_mouse$X1[i])
  stops = gregexpr(pattern = "\\(", codon_mouse$X1[i])
  for (j in 1:4) {
    temp = substr(codon_mouse$X1[i], starts[[1]][j], stops[[1]][j] - 2)
    codontemp = substr(temp, 1, 3)
    valuetemp = substr(temp, gregexpr("[0-9]", temp)[[1]][1], nchar(temp))
    codon_all$Mm[codon_all$codon == tolower(codontemp)] = as.double(valuetemp)
  }
}
Mm_sum = aggregate(codon_all$Mm, by = list(aa), sum)
colnames(Mm_sum) = c("aa", "Mm_sum")
codon_all = merge(codon_all, Mm_sum, by = "aa")
codon_all$Mm_fraction = codon_all$Mm / codon_all$Mm_sum
Mm_max = aggregate(codon_all$Mm_fraction, by = list(codon_all$aa), max)
colnames(Mm_max) = c("aa", "Mm_fraction_max")
codon_all = merge(codon_all, Mm_max, by = "aa")
codon_all$Mm_relative = codon_all$Mm_fraction / codon_all$Mm_fraction_max

### sort data
codon_all = codon_all[order(codon_all$codon),]


## calculating cais
sequence_names = names(sequences)
sequence_numbers = length(sequence_names)
result = data.frame(name = sequence_names, OlCAI = numeric(sequence_numbers), HsCAI = numeric(sequence_numbers), MmCAI = numeric(sequence_numbers))

for (i in 1:sequence_numbers) {
  currentfp = names(sequences)[i]
  caitemp = cai(sequences[[currentfp]], codon_all$Hs_relative, numcode = 1)
  result$HsCAI[result$name == names(sequences)[i]] = caitemp
}

for (i in 1:sequence_numbers) {
  currentfp = names(sequences)[i]
  caitemp = cai(sequences[[currentfp]], codon_all$Ol_relative, numcode = 1)
  result$OlCAI[result$name == names(sequences)[i]] = caitemp
}

for (i in 1:sequence_numbers) {
  currentfp = names(sequences)[i]
  caitemp = cai(sequences[[currentfp]], codon_all$Mm_relative, numcode = 1)
  result$MmCAI[result$name == names(sequences)[i]] = caitemp
}

##s ave results as xlsx file for overview
condformat2excel(result, filename = "result", sheet_name = "Sheet1", overwrite_wb = TRUE,
                 overwrite_sheet = TRUE)

## label for plot1
result$seqlabel = as.character(result$name)
result$seqlabel[!result$seqlabel %in% plot1_label] = ""

## plot1 Oryzias latipes vs. Homo sapiens plots all values except excluded in plot1_noplot and only labels plot1_label
plot1_OlHs = ggplot(result[!result$name %in% plot1_noplot,], aes(x = HsCAI, y = OlCAI)) +
  geom_point() +
  theme_bw() + 
  ggtitle(expression(paste("Comparison ", italic("O. latipes"), " vs. ", italic("H. sapiens"), " CAI"))) +
  xlab(expression(paste("CAI ", italic("Homo sapiens")))) + 
  ylab(expression(paste("CAI ", italic("Oryzias latipes")))) +
  theme(legend.position="none") +
  geom_abline() +
  xlim(0.6,1) +
  ylim(0.6,1) +
  geom_text_repel(aes(label = seqlabel), size = 3.5)

## plot2 Oryzias latipes vs. Homo sapiens plots only the selected values in plot2_plot
plot2_OlHs = ggplot(result[result$name %in% plot2_plot,], aes(x = HsCAI, y = OlCAI)) +
  geom_point() +
  theme_bw() + 
  ggtitle(expression(paste("Comparison ", italic("O. latipes"), " vs. ", italic("H. sapiens"), " CAI"))) +
  xlab(expression(paste("CAI ", italic("Homo sapiens")))) + 
  ylab(expression(paste("CAI ", italic("Oryzias latipes")))) + 
  theme(legend.position="none") +
  geom_abline() +
  xlim(0.6,1) +
  ylim(0.6,1) +
  geom_text_repel(aes(label = name), size = 3.5)

## plot3 Oryzias latipes vs. Homo sapiens plots all values and all labels
plot3_OlHs = ggplot(result[!result$name %in% plot3_noplot,], aes(x = HsCAI, y = OlCAI)) +
  geom_point() +
  theme_bw() + 
  ggtitle(expression(paste("Comparison ", italic("O. latipes"), " vs. ", italic("H. sapiens"), " CAI"))) +
  xlab(expression(paste("CAI ", italic("Homo sapiens")))) + 
  ylab(expression(paste("CAI ", italic("Oryzias latipes")))) + 
  theme(legend.position="none") +
  geom_abline() +
  xlim(0.6,1) +
  ylim(0.6,1) +
  geom_text_repel(aes(label = name), size = 2)

ggsave("plot1_OlHs.pdf", plot1_OlHs, width = 10, height = 6, scale = 0.6)
ggsave("plot2_OlHs.pdf", plot2_OlHs, width = 10, height = 6, scale = 0.6)
ggsave("plot3_OlHs.pdf", plot3_OlHs, width = 10, height = 10, scale = 1)

## plot1 Oryzias latipes vs. Mus musculus plots all values except excluded in plot1_noplot and only labels plot1_label
plot1_OlMm = ggplot(result[!result$name %in% plot1_noplot,], aes(x = MmCAI, y = OlCAI)) +
  geom_point() +
  theme_bw() + 
  ggtitle(expression(paste("Comparison ", italic("O. latipes"), " vs. ", italic("M. musculus"), " CAI"))) +
  xlab(expression(paste("CAI ", italic("Mus musculus")))) + 
  ylab(expression(paste("CAI ", italic("Oryzias latipes")))) +
  theme(legend.position="none") +
  geom_abline() +
  xlim(0.6,1) +
  ylim(0.6,1) +
  geom_text_repel(aes(label = seqlabel), size = 3.5)

## plot2 Oryzias latipes vs. Mus musculus plots only the selected values in plot2_plot
plot2_OlMm = ggplot(result[result$name %in% plot2_plot,], aes(x = MmCAI, y = OlCAI)) +
  geom_point() +
  theme_bw() + 
  ggtitle(expression(paste("Comparison ", italic("O. latipes"), " vs. ", italic("M. musculus"), " CAI"))) +
  xlab(expression(paste("CAI ", italic("Mus musculus")))) + 
  ylab(expression(paste("CAI ", italic("Oryzias latipes")))) + 
  theme(legend.position="none") +
  geom_abline() +
  xlim(0.6,1) +
  ylim(0.6,1) +
  geom_text_repel(aes(label = name), size = 3.5)

## plot3 Oryzias latipes vs. Mus musculus plots all values and all labels
plot3_OlMm = ggplot(result[!result$name %in% plot3_noplot,], aes(x = HsCAI, y = OlCAI)) +
  geom_point() +
  theme_bw() + 
  ggtitle(expression(paste("Comparison ", italic("O. latipes"), " vs. ", italic("M. musculus"), " CAI"))) +
  xlab(expression(paste("CAI ", italic("Mus musculus")))) + 
  ylab(expression(paste("CAI ", italic("Oryzias latipes")))) + 
  theme(legend.position="none") +
  geom_abline() +
  xlim(0.6,1) +
  ylim(0.6,1) +
  geom_text_repel(aes(label = name), size = 2)

ggsave("plot1_OlMm.pdf", plot1_OlMm, width = 10, height = 6, scale = 0.6)
ggsave("plot2_OlMm.pdf", plot2_OlMm, width = 10, height = 6, scale = 0.6)
ggsave("plot3_OlMm.pdf", plot3_OlMm, width = 10, height = 10, scale = 1)