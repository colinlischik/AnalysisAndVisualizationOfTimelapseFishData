# plotting the experimental data established with the 3 previous scripts
library(data.table)
library(ggplot2)

#------------------change these variables------------------------------

## set the working directory
workingdirectory = "C:\\Users\\Colin_Lischik\\R\\"
## settings for the plot
titlename = "Comparison of anesthetics over time"
xlabel = "imaging time post stage 28 [h]"
ylabel = "normalized movement index\n [A.U.]"
colorscale = c("#762a83", "#af8dc3", "#e7d4e8", "#d9f0d3", "#7fbf7b", "#1b7837") ## needs to be at least the lenght of the number of experiments
savingdirectory = workingdirectory
plotname = "anesthetic comparison.pdf"
plotwidth = 20
plotheight = 6
plotscale = 0.45

#------------------do not change anything from here to the next note-----------------
setwd(workingdirectory)

## loading data
datain = fread("measurements_dropped_linked.csv", sep = ",", drop = c("V1", "X", "X.1", "Min"))
datain$h = datain$min / 60

## only use positive timepoints (negative timepoints can happen by adjusting the starting stage of plates)
datain = datain[datain$h >= 0]

## normalize to first timepoint
datain_norm = as.data.table(datain)
setDT(datain_norm)[,Mean_norm := Mean/Mean[min == 0][1L], by = c("plate", "well")]
setDT(datain_norm)[,Median_norm := Median/Median[min == 0][1L], by = c("plate", "well")]
setDT(datain_norm)[,Max_norm := Max/Max[min == 0][1L], by = c("plate", "well")]
setDT(datain_norm)[,STD_norm := StdDev/StdDev[min == 0][1L], by = c("plate", "well")]

#datain_norm$condition[datain_norm$condition == "Cabs uninjected"] = "wildtype control"

## levels for plotting n
levels = levels(as.factor(datain_norm$condition))
levels_table = table(datain_norm$condition[datain_norm$min == 0])
levels_n = NULL
for (i in 1:length(levels)) {
  levels_n[i] = paste(names(levels_table)[i], " (n = ", levels_table[i], ")", sep = "")
}
#------------------this can also be changed if needed-----------------

## possibility to change the legend names and/or add italic writing to the legend

levels_n[1] = expression(paste(italic(alpha), italic("-Bungarotoxin"),  " mRNA (n = 18)"))
levels_n[4] = expression("Mock injection (n = 23)")
levels_n[6] = expression("Wild-type control (n = 5)")

#------------------do not change anything from here on-----------------

## plotting experiments
pmean_norm = ggplot(datain_norm, aes(x = h, y = Mean_norm, group = condition, colour = condition)) +
  geom_smooth() +
  theme_bw(base_size=10) + 
  ggtitle(paste(titlename, "(mean with 95% confidence intervals)")) +
  xlab(xlabel) + 
  ylab(ylabel) + 
  theme(legend.title=element_blank(), text = element_text(size=12)) +
  scale_colour_manual(breaks = levels, labels = levels_n, values = colorscale)
pmean_norm

setwd(savingdirectory)
ggsave(plotname, pmean_norm, width = plotwidth, height = plotheight, scale = plotscale)
