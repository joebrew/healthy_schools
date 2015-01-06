#####
# CHOROPLETH MAP
#####
choro <- function(
  shape = NULL,
  boundary = NULL,
  main = NULL,
  var = NULL,
  color1 = "lightblue",
  color2 = "darkorange",
  legend_round = 2,
  legend_pos = "bottomleft",
  long_legend = TRUE,
  fixed_scale = NULL,
  lwd = 0.2,
  border = TRUE,
  legend_text_col = "black",
  add = FALSE){
  my_colors <- colorRampPalette(c(color1, "white", color2))(10)
  if(!is.null(fixed_scale)){
    if(length(fixed_scale) != 10){stop("Fixed scale must be of length 10")}
    my_quantiles <- fixed_scale
  } else{
    my_quantiles <- quantile(var, na.rm = TRUE, probs = seq(0,1, length = 10))
  }
  my_values <- vector(mode = "numeric", length = length(var))
  for (i in 1:length(var)){
    diffs <- (var[i] - as.numeric(my_quantiles))^2
    best <- which.min(diffs)[1]
    my_values[i] <- best
  }
  map_colors <- my_colors[my_values]
  plot(shape, col = map_colors, border = border, lwd = lwd,
       main = main, add = add)
  plot(boundary, add = TRUE)
  if(long_legend){
    legend_colors <- colorRampPalette(my_colors)(25)
    legend(legend_pos, # position
           legend = c(min(round(my_quantiles, digits = legend_round)),
                      rep(NA, 11),
                      median(round(my_quantiles, digits = legend_round)),
                      rep(NA, 11),
                      max(round(my_quantiles, digits = legend_round))),
           fill = legend_colors,
           cex = 0.75,
           y.intersp = 0.5,
           border=NA,
           bty = "n",
           text.col = legend_text_col)
  } else{
    legend_colors <- colorRampPalette(my_colors)(11)
    legend(legend_pos, # position
           legend = c(min(round(my_quantiles, digits = legend_round)),
                      rep(NA, 4),
                      median(round(my_quantiles, digits = legend_round)),
                      rep(NA, 4),
                      max(round(my_quantiles, digits = legend_round))),
           fill = legend_colors,
           cex = 0.75,
           y.intersp = 0.5,
           border=NA,
           bty = "n",
           text.col = legend_text_col)
  }
}