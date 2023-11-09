rm(list=ls())

library(haven)
Real_income_to_seasonal_adjust <- read_dta("C:/Users/juanf/Documents/FSS/Data_processing/Real_income_to_seasonal_adjust.dta")
View(Real_income_to_seasonal_adjust)

# Filter by each state/province
y = as.matrix(Real_income_to_seasonal_adjust$real_income)
y_1 = as.data.frame(Real_income_to_seasonal_adjust$real_income[Real_income_to_seasonal_adjust$DPTO== 5])

serie_antioquia = ts(data=y_1, start=c(2020,1),frequency=12)
plot(serie_antioquia,main="Real Income (Antioquia)" ,col='tomato',lwd=2,ylab='',xlab='', type='l')


library(seasonal)

Y <- seas(serie_antioquia,regression.aictest = c("td"))
names(Y)
Y$data
attributes(Y$data)


original(Y)
final(Y)
resid(Y) 
coef(Y)
fivebestmdl(Y)
out(Y)                  # genera un X-13 .out file en versi?n HTML 
spc(Y)

plot(Y)
summary(Y)

plot(Y)
plot(Y, trend = TRUE)

monthplot(Y)
monthplot(Y, choice = "irregular")

pacf(resid(Y))
plot(density(resid(Y)))
qqnorm(resid(Y))

qqnorm(as.matrix(resid(Y)),xlab='Cuantiles dist. normal',ylab='Cuantiles emp?ricos',pch=19,col='steelblue', ,main='Q-Q Residuales de la SA')
qqline(as.matrix(resid(Y)),lty=2,lwd=2,col="tomato")
# Yes, it has seasonal component
real_income_sa_ant = final(Y)
x11()
plot(real_income_sa_ant)
x11()
plot(Y)

# lets do it for every state
x = as.matrix(Real_income_to_seasonal_adjust$real_income)

rm(list=ls())

library(haven)
library(seasonal)
Real_income_to_seasonal_adjust <- read_dta("C:/Users/juanf/Documents/FSS/Data_processing/Real_income_to_seasonal_adjust.dta")

# Nariño
x_1 = as.data.frame(Real_income_to_seasonal_adjust$real_income[Real_income_to_seasonal_adjust$DPTO== 52])
serie_narino = ts(data=x_1, start=c(2020,1),frequency=12)
Y_narino <- seas(serie_narino,regression.aictest = c("td"))

# Norte de Santander
x_2 = as.data.frame(Real_income_to_seasonal_adjust$real_income[Real_income_to_seasonal_adjust$DPTO== 54])
serie_NDS = ts(data=x_2, start=c(2020,1),frequency=12)
Y_NDS <- seas(serie_NDS,regression.aictest = c("td"))

# Cauca
x_3 = as.data.frame(Real_income_to_seasonal_adjust$real_income[Real_income_to_seasonal_adjust$DPTO== 19])
serie_cauca = ts(data=x_3, start=c(2020,1),frequency=12)
Y_cauca <- seas(serie_cauca,regression.aictest = c("td"))

# Antioquia
x_4 = as.data.frame(Real_income_to_seasonal_adjust$real_income[Real_income_to_seasonal_adjust$DPTO== 5])
serie_antioquia = ts(data=x_4, start=c(2020,1),frequency=12)
Y_antioquia <- seas(serie_antioquia,regression.aictest = c("td"))

# Bolivar
x_5 = as.data.frame(Real_income_to_seasonal_adjust$real_income[Real_income_to_seasonal_adjust$DPTO== 13])
serie_bolivar = ts(data=x_5, start=c(2020,1),frequency=12)
Y_bolivar <- seas(serie_bolivar,regression.aictest = c("td"))

# Cordoba
x_6 = as.data.frame(Real_income_to_seasonal_adjust$real_income[Real_income_to_seasonal_adjust$DPTO== 23])
serie_cordoba = ts(data=x_6, start=c(2020,1),frequency=12)
Y_cordoba <- seas(serie_cordoba,regression.aictest = c("td"))

# Caqueta
x_7 = as.data.frame(Real_income_to_seasonal_adjust$real_income[Real_income_to_seasonal_adjust$DPTO== 18])
serie_caqueta = ts(data=x_7, start=c(2020,1),frequency=12)
Y_caqueta <- seas(serie_caqueta,regression.aictest = c("td"))

# Choco
x_8 = as.data.frame(Real_income_to_seasonal_adjust$real_income[Real_income_to_seasonal_adjust$DPTO== 27])
serie_choco = ts(data=x_8, start=c(2020,1),frequency=12)
Y_choco <- seas(serie_choco,regression.aictest = c("td"))

real_income_sa_narino = final(Y_narino)
real_income_sa_NDS = final(Y_NDS)
real_income_sa_cauca = final(Y_cauca)
real_income_sa_antioquia = final(Y_antioquia)
real_income_sa_bolivar = final(Y_bolivar)
real_income_sa_cordoba = final(Y_cordoba)
real_income_sa_caqueta = final(Y_caqueta)
real_income_sa_choco = final(Y_choco)


real_income_SA = as.data.frame(real_income_sa_narino)
colnames(real_income_SA) = "V52"
real_income_SA["V54"] = as.data.frame(real_income_sa_NDS)
real_income_SA["V19"] = as.data.frame(real_income_sa_cauca)
real_income_SA["V5"] = as.data.frame(real_income_sa_antioquia)
real_income_SA["V13"] = as.data.frame(real_income_sa_bolivar)
real_income_SA["V23"] = as.data.frame(real_income_sa_cordoba)
real_income_SA["V18"] = as.data.frame(real_income_sa_caqueta)
real_income_SA["V27"] = as.data.frame(real_income_sa_choco)


real_income_SA= cbind(expand.grid(c(1:12), 2020:2023)[1:44,],real_income_SA)
names(real_income_SA)[1:2] = c("Month","Year")

# save data
write_dta(real_income_SA, "C:/Users/juanf/Documents/FSS/Data_processing/real_income_SA.dta")
