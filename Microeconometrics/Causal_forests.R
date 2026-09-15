
library(patchwork)
library(grf)
library(readr)
library(dplyr)
library(ggplot2)

mydf <- read.csv(
  "C:\\Users\\Ivan\\Desktop\\Study\\Microeconometrics\\Assignment\\files2\\expanded_data.csv"
)

## a)

Y <- mydf$div_rate_sim

mydf$W <- ifelse(
  !is.na(mydf$lfdivlaw) & mydf$year >= mydf$lfdivlaw,
  1,
  0
)
W <- mydf$W

X <- model.matrix(
  ~ education_rate +
    childcare_availability +
    unemployment_rate +
    median_income +
    urbanization +
    marriage_rate +
    religious_adherence +
    alcohol_consumption +
    domestic_violence_rate +
    women_labor_force_participation +
    housing_cost +
    crime_rate +
    social_services_spending,
  data = mydf
)[, -1]


##causal forest
tau.forest <- causal_forest(X, Y, W)


## add a a column for each, these are CATE for every observation
mydf$tau_hat <- predict(tau.forest)$predictions


## calculate pooled CATE
CATE <- average_treatment_effect(tau.forest) 
##0.1137, 0.0358

### (b)
## (i)

forest.Y <- regression_forest(X, Y, tune.parameters = "all")
var_imp <- variable_importance(forest.Y)

varimp_table <- data.frame(
  variable = colnames(X),
  importance = var_imp
) %>%
  arrange(desc(importance))

print(varimp_table)

## choose top predictors based on variable importance
top_vars <- varimp_table$variable[1:5]
print(top_vars)

## estimate linear projection of estimated CATE on selected predictors
projection_formula <- as.formula(
  paste("tau_hat ~", paste(top_vars, collapse = " + "))
)

blp_lm <- lm(projection_formula, data = mydf)
summary(blp_lm)

## (b) (ii)

set.seed(123)
n <- nrow(X)
train <- sample(1:n, floor(n / 2))


## split into 2 parts to satisfy honesty requirement
train.forest <- causal_forest(X[train, ], Y[train], W[train])
eval.forest <- causal_forest(X[-train, ], Y[-train], W[-train])

rate <- rank_average_treatment_effect(
  eval.forest,
  predict(train.forest, X[-train, ])$predictions
)

plot(rate)
##heterogeneity present, as evidenced by downward slope of the curve


## check which covariate drives heterogeneity

p1 <- ggplot(mydf, aes(x = urbanization, y = tau_hat)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "loess") +
  labs(
    title = "Urbanization",
    x = "Urbanization",
    y = "Estimated CATE"
  )

p2 <- ggplot(mydf, aes(x = religious_adherence, y = tau_hat)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "loess") +
  labs(
    title = "Religious adherence",
    x = "Religious adherence",
    y = "Estimated CATE"
  )

p3 <- ggplot(mydf, aes(x = median_income, y = tau_hat)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "loess") +
  labs(
    title = "Median income",
    x = "Median income",
    y = "Estimated CATE"
  )

p4 <- ggplot(mydf, aes(x = education_rate, y = tau_hat)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "loess") +
  labs(
    title = "Education rate",
    x = "Education rate",
    y = "Estimated CATE"
  )

p5 <- ggplot(mydf, aes(x = women_labor_force_participation, y = tau_hat)) +
  geom_point(alpha = 0.25) +
  geom_smooth(method = "loess") +
  labs(
    title = "Women's labor force participation",
    x = "Women's labor force participation",
    y = "Estimated CATE"
  )

(p1 | p2) / (p3 | p4) / p5

##negative association between religion and CATE. Religious families value stable marriages more? education has positive association at the top of distribution - no clear explanation. Female participation- working females are less dependent from husbands, which explains more divorces?


## (c)

#There is evidence of heterogeneity, driven primarily by religion. TOC shows that there is substantial gain from using causal forest predictions.

## (d) 
# Honest trees split the sample set into two nonoverlapping sets - a region on which to decide where to split, and a hold-out subsample for estimation of \tau.

tau.forest_hon <- causal_forest(X, Y, W, honesty = FALSE)

## estimated CATE for each observation
mydf$tau_hat_1 <- predict(tau.forest)$predictions

## average treatment effect
CATE_hon <- average_treatment_effect(tau.forest)
print(CATE)

## 0.117 (0.035)

##no significant difference. bias tends to become substantial when the sample has not enough information or too many variables relative to information. Here, this is not the case with our data.

