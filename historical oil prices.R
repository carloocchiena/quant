library(quantmod)

getSymbols("DCOILWTICO", src = "FRED", auto.assign = TRUE)
oil_xts <- na.omit(DCOILWTICO)

df <- data.frame(
  Date = index(oil_xts),
  Price = as.numeric(oil_xts)
)

df$Year  <- as.integer(format(df$Date, "%Y"))
df$Month <- as.integer(format(df$Date, "%m"))

df$CumRet <- do.call(c, lapply(split(df$Price, df$Year), function(x) {
  log(x / x[1])
}))

df <- df[is.finite(df$CumRet), ]

years    <- unique(df$Year)
y_limits <- range(df$CumRet, na.rm = TRUE)

par(bg = "black", col.axis = "white", col.lab = "white",
    col.main = "white", fg = "white")

plot(1:12, type = "n", xlim = c(1, 12), ylim = y_limits,
     xaxt = "n",
     xlab = "Month",
     ylab = "Cumulative Log Return (Base 0 = Jan)",
     main = "WTI Seasonal Analysis (1986-2026)")

axis(1, at = 1:12, labels = month.abb)

for (y in years) {
  yearly_data <- subset(df, Year == y)
  m_data      <- aggregate(CumRet ~ Month, data = yearly_data, FUN = mean)
  
  is_current  <- (y == max(years))
  line_color  <- if (is_current) "magenta" else rgb(1, 1, 1, alpha = 0.15)
  line_lwd    <- if (is_current) 2 else 1
  
  lines(m_data$Month, m_data$CumRet, col = line_color, lwd = line_lwd)
}



# # EXPORT DATA TO EXCEL
# monthly_prices <- aggregate(Price ~ Month + Year, data = df, FUN = mean)
# df_export <- as.data.frame(df)
# monthly_prices <- aggregate(Price ~ Month + Year, data = df_export, FUN = mean)
# excel_pivot <- reshape(monthly_prices, 
#                        idvar = "Month", 
#                        timevar = "Year", 
#                        direction = "wide")
# 
# colnames(excel_pivot) <- gsub("Price.", "", colnames(excel_pivot))
# excel_pivot <- excel_pivot[order(excel_pivot$Month), ]
# excel_pivot$Month <- month.abb[excel_pivot$Month]
# 
# if(!require(writexl)) install.packages("writexl")
# writexl::write_xlsx(excel_pivot, path = "WTI_Pivot_Prices.xlsx")
# 
# cat("File Excel creato con successo!")