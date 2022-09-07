The Relationship between Deprivation & Health Outcomes
================
Paul Johnson
2022-09-07

- <a href="#frequentist-vs-bayesian-statistics-a-primer"
  id="toc-frequentist-vs-bayesian-statistics-a-primer">Frequentist Vs
  Bayesian Statistics: A Primer</a>
- <a
  href="#visual-exploration-of-deprivation-and-health-inequalities-data"
  id="toc-visual-exploration-of-deprivation-and-health-inequalities-data">Visual
  Exploration of Deprivation and Health Inequalities Data</a>
- <a href="#linear-regression-the-frequentist-way"
  id="toc-linear-regression-the-frequentist-way">Linear Regression the
  Frequentist Way</a>
- <a href="#bayesian-regression" id="toc-bayesian-regression">Bayesian
  Regression</a>
  - <a href="#setting-priors" id="toc-setting-priors">Setting Priors</a>
  - <a href="#specify-stan-model" id="toc-specify-stan-model">Specify Stan
    Model</a>
  - <a href="#diagnostic-checks" id="toc-diagnostic-checks">Diagnostic
    Checks</a>
  - <a href="#posterior-checks" id="toc-posterior-checks">Posterior
    Checks</a>
  - <a href="#estimated-parameter-values"
    id="toc-estimated-parameter-values">Estimated Parameter Values</a>
- <a href="#explore-stan-model-using-shiny"
  id="toc-explore-stan-model-using-shiny">Explore Stan Model Using
  Shiny</a>

## Frequentist Vs Bayesian Statistics: A Primer

At its core, Frequentist vs Bayesian differences lie in the definition
of probability.

Frequentists think of probability in terms of frequencies. The
probability of an event is a measure of the frequency of that event
after repeated measurements. Bayesians, however, incorporate uncertainty
as a part of probability.

For Bayesians, probability is an attempt to define the plausability of a
proposition/situation.

In Bayesian statistics, the p-value is not a value, but a distribution
(or in reality, the p-value is not relevant).

At a very basic level, the fundamental difference between the
Frequentist and Bayesian frameworks are that Bayesian inference includes
any prior expectations and knowledge that can help in drawing
inferences.

Frequentist probability - If you ran the same simulation again and
again, the probability that you observe the outcome

Bayesian probability

In reality, I think that Bayesian approaches to probability are a lot
more intuitive than Frequentist approaches. You have to train your mind
to think like a Frequentist, whereas our natural way of understanding
probabilities is inherently Bayesian.

## Visual Exploration of Deprivation and Health Inequalities Data

``` r
deprivation_df %>%
  psych::describe() %>%
  filter(!row_number() %in% c(1, 2)) %>%
  select(
    -vars, -n, -trimmed, -mad,
    -skew, -kurtosis, -se, -range
  ) %>%
  relocate(sd, .after = median) %>%
  knitr::kable(digits = 2)
```

|                            |   mean | median |    sd |    min |    max |
|:---------------------------|-------:|-------:|------:|-------:|-------:|
| life_expectancy            |  81.15 |  81.16 |  1.55 |  76.86 |  85.22 |
| mortality                  | 193.02 | 190.00 | 39.42 | 118.90 | 328.37 |
| imd_score                  |  23.17 |  22.84 |  8.05 |   5.85 |  45.04 |
| imd_decile                 |   5.45 |   5.00 |  2.83 |   1.00 |  10.00 |
| physiological_risk_factors |  99.68 |  98.70 |  9.72 |  80.20 | 125.90 |
| behavioural_risk_factors   |  99.36 | 100.60 |  8.61 |  72.40 | 118.30 |

``` r
deprivation_df %>%
  ggplot(aes(life_expectancy, imd_score)) +
  geom_point() +
  labs(x = "Life Expectancy", y = "IMD Score")
```

![](01-deprivation_files/figure-gfm/imd-score-eda-1.png)

``` r
deprivation_df %>%
  ggplot(aes(life_expectancy, physiological_risk_factors)) +
  geom_point() +
  labs(x = "Life Expectancy", y = "Physiological Risk Factors")
```

![](01-deprivation_files/figure-gfm/health-index-eda-1.png)

``` r
deprivation_df %>%
  ggplot(aes(life_expectancy, behavioural_risk_factors)) +
  geom_point() +
  labs(x = "Life Expectancy", y = "Behavioural Risk Factors")
```

![](01-deprivation_files/figure-gfm/health-index-eda-2.png)

``` r
deprivation_df %>%
  select(
    life_expectancy,
    physiological_risk_factors,
    behavioural_risk_factors,
    imd_score
  ) %>%
  group_by(area_code) %>%
  summarise_all(.funs = "mean") %>%
  correlation::correlation(bayesian = TRUE) %>%
  summary() %>%
  knitr::kable(digit = 2)
```

| Parameter                  | imd_score | behavioural_risk_factors | physiological_risk_factors |
|:---------------------------|----------:|-------------------------:|---------------------------:|
| life_expectancy            |     -0.84 |                     0.91 |                       0.56 |
| physiological_risk_factors |     -0.38 |                     0.54 |                            |
| behavioural_risk_factors   |     -0.84 |                          |                            |

There are strong correlations between life expectancy and the three
independent variables, however, the correlation between IMD score and
the two risk factor variables is also relatively strong, and in the case
of behavioural risk factors, it is very strong. This could be an issue.

``` r
deprivation_df %>%
  ggplot(aes(imd_score, physiological_risk_factors)) +
  geom_point() +
  labs(x = "IMD Score", y = "Physiological Risk Factors")
```

![](01-deprivation_files/figure-gfm/correlation-eda-1.png)

``` r
deprivation_df %>%
  ggplot(aes(imd_score, behavioural_risk_factors)) +
  geom_point() +
    labs(x = "IMD Score", y = "Behavioural Risk Factors")
```

![](01-deprivation_files/figure-gfm/correlation-eda-2.png)

``` r
deprivation_df %>%
  mutate(imd_decile = as.factor(imd_decile)) %>%
  ggplot(aes(physiological_risk_factors, imd_decile)) +
  ggridges::geom_density_ridges() +
  labs(x = "Physiological Risk Factors", y = "IMD Decile")
```

![](01-deprivation_files/figure-gfm/correlation-eda-3.png)

``` r
deprivation_df %>%
  mutate(imd_decile = as.factor(imd_decile)) %>%
  ggplot(aes(behavioural_risk_factors, imd_decile)) +
  ggridges::geom_density_ridges() +
  labs(x = "Behavioural Risk Factors", y = "IMD Decile")
```

![](01-deprivation_files/figure-gfm/correlation-eda-4.png)

The correlations are a little more obvious when plotted and inspected
visually. The behavioural risk factors have a positive linear
relationship with IMD (as the value of the risk factor goes up, so does
IMD score/decile).

## Linear Regression the Frequentist Way

First we will transform each of the explanatory variables to make them a
little easier to interpret (particularly with regard to the intercept).

These transformations won’t impact the regression results, but will just
make the results easier to explain, as the intercept is no longer based
on zero values of each explanatory variable (which are effectively
meaningless, especially in the Health Index variables).

``` r
mean_imd <- mean(deprivation_df$imd_score)

deprivation_df <-
  deprivation_df %>%
  mutate(
    imd_transformed = imd_score - mean_imd,
    physiological_transformed = physiological_risk_factors - 100,
    behavioural_transformed = behavioural_risk_factors - 100
  )
```

The frequentist regression is very easy to compute, using `lm()`.

``` r
life_expectancy_ols <-
  lm(life_expectancy ~ imd_transformed + physiological_transformed + behavioural_transformed,
    data = deprivation_df
  )

sjPlot::tab_model(
  life_expectancy_ols,
  pred.labels =
    c(
      "Intercept",
      "IMD Score",
      "Physiological Risk Factors",
      "Behavioural Risk Factors"
    ),
  dv.labels = c("Life Expectancy")
)
```

<table style="border-collapse:collapse; border:none;">
<tr>
<th style="border-top: double; text-align:center; font-style:normal; font-weight:bold; padding:0.2cm;  text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:normal; font-weight:bold; padding:0.2cm; ">Life Expectancy</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">Intercept</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">81.22</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">81.15&nbsp;&ndash;&nbsp;81.29</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">IMD Score</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.07</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.08&nbsp;&ndash;&nbsp;-0.05</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">Physiological Risk Factors</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02&nbsp;&ndash;&nbsp;0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">Behavioural Risk Factors</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.10</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.08&nbsp;&ndash;&nbsp;0.11</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left; border-top:1px solid;" colspan="3">292</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">R<sup>2</sup> / R<sup>2</sup> adjusted</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">0.856 / 0.854</td>
</tr>

</table>

The results suggest that each of the explanatory variables has a small
but significant effect on life expectancy. As deprivation increases (IMD
score increases), life expectancy decreases, while as the index score
representing physiological and behavioural risk factors (meaning a
better performance in that Health Index subdomain) increases, life
expectancy increases.

## Bayesian Regression

### Setting Priors

First we need to come up with some priors. Given everything we already
know about life expectancy at birth and the effect that deprivation has
on health outcomes, we should be able to constrain our prior
distribution in relatively informative ways.

First, we would expect life expectancy at birth to be normally
distributed around 80.

With IMD scores, we can reasonably expect that we should observe a
negative relationship on health outcomes as deprivation increases,
meaning that as IMD scores increase (meaning higher deprivation), life
expectancy should decrease. The effect is unlikely to be huge, so we
will conservatively estimate that each one unit increase in IMD score
will be associated with a one unit decrease in life expectancy at birth.
The key here is more the standard error, which we will constraint
sufficiently to mean that our prior is that deprivation will only have a
negative effect on life expectancy.

We have similar expectations of the physiological

``` r
life_expectancy_priors <-
  stan_glm(
    life_expectancy ~ imd_transformed + physiological_transformed + behavioural_transformed,
    data = deprivation_df,
    prior_intercept = normal(80, 1),
    prior = normal(location = c(-1, 1, 1), scale = c(0.25, 0.5, 0.25)),
    prior_PD = TRUE
  )
```

We can see a summary of our priors here:

``` r
# prior_summary(life_expectancy_priors)

# bayestestR::describe_prior(life_expectancy_priors)

life_expectancy_priors %>%
  bayestestR::describe_prior() %>%
  knitr::kable(digits = 2)
```

| Parameter                 | Prior_Distribution | Prior_Location | Prior_Scale |
|:--------------------------|:-------------------|---------------:|------------:|
| (Intercept)               | normal             |             80 |        1.00 |
| imd_transformed           | normal             |             -1 |        0.25 |
| physiological_transformed | normal             |              1 |        0.50 |
| behavioural_transformed   | normal             |              1 |        0.25 |

The prior distributions look pretty sensible:

``` r
plot(life_expectancy_priors, "hist")
```

![](01-deprivation_files/figure-gfm/prior-plot-1.png)

### Specify Stan Model

``` r
life_expectancy_glm <-
  stan_glm(
    life_expectancy ~ imd_transformed + physiological_transformed + behavioural_transformed,
    data = deprivation_df,
    prior_intercept = normal(80, 1),
    prior = normal(location = c(-1, 1, 1), scale = c(0.25, 0.5, 0.25))
  )
```

``` r
sjPlot::tab_model(
  life_expectancy_glm,
  pred.labels =
    c(
      "Intercept",
      "IMD Score",
      "Physiological Risk Factors",
      "Behavioural Risk Factors"
    ),
  dv.labels = c("Life Expectancy")
)
```

<table style="border-collapse:collapse; border:none;">
<tr>
<th style="border-top: double; text-align:center; font-style:normal; font-weight:bold; padding:0.2cm;  text-align:left; ">&nbsp;</th>
<th colspan="2" style="border-top: double; text-align:center; font-style:normal; font-weight:bold; padding:0.2cm; ">Life Expectancy</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">CI (95%)</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">Intercept</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">81.22</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">81.15&nbsp;&ndash;&nbsp;81.29</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">IMD Score</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.07</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.08&nbsp;&ndash;&nbsp;-0.05</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">Physiological Risk Factors</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02&nbsp;&ndash;&nbsp;0.03</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">Behavioural Risk Factors</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.10</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.08&nbsp;&ndash;&nbsp;0.11</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left; border-top:1px solid;" colspan="2">292</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">R<sup>2</sup> Bayes</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="2">0.854</td>
</tr>

</table>

### Diagnostic Checks

``` r
# bayestestR::sensitivity_to_prior(life_expectancy_glm)

life_expectancy_priors %>%
  bayestestR::sensitivity_to_prior() %>%
  knitr::kable(digits = 2)
```

| Parameter                 | Sensitivity_Median |
|:--------------------------|-------------------:|
| imd_transformed           |               3.51 |
| physiological_transformed |               5.98 |
| behavioural_transformed   |               3.49 |

``` r
# bayestestR::diagnostic_posterior(life_expectancy_glm)

life_expectancy_priors %>%
  bayestestR::diagnostic_posterior() %>%
  knitr::kable(digits = 2)
```

| Parameter                 | Rhat |     ESS | MCSE |
|:--------------------------|-----:|--------:|-----:|
| (Intercept)               |    1 | 4432.07 | 0.02 |
| behavioural_transformed   |    1 | 3718.00 | 0.00 |
| imd_transformed           |    1 | 4633.47 | 0.00 |
| physiological_transformed |    1 | 4605.13 | 0.01 |

### Posterior Checks

``` r
# posterior predictive checks

life_expectancy_posterior <- as.matrix(life_expectancy_glm)

#
# bayesplot::ppc_dens_overlay(
#   y = life_expectancy_glm$y,
#   yrep = posterior_predict(
#     life_expectancy_glm,
#     draws = 50
#     )
#   ) +
#   labs(
#     title = "Posterior Predictive Checks Against Observed Data",
#     subtitle = "Samples Drawn from Posterior Predictive Distribution of Life Expectancy\nby IMD Score and Physiological & Behavioural Risk Factors",
#     x = "Life Expectancy"
#     )

life_expectancy_rep <- posterior_predict(life_expectancy_glm)

n_sims <- nrow(life_expectancy_rep)
subset <- sample(n_sims, 100)

bayesplot::ppc_dens_overlay(deprivation_df$life_expectancy, life_expectancy_rep[subset, ])
```

![](01-deprivation_files/figure-gfm/posterior-checks-1.png)

``` r
facet_names <- 
  as_labeller(
    c(
    `(Intercept)` = "Intercept",
    `behavioural_transformed` = "Behavioural Risk Factors",
    `imd_transformed` = "IMD Score",
    `physiological_transformed` = "Physiological Risk Factors",
    `sigma` = "Sigma"
    )
  )

posterior_vs_prior(
  life_expectancy_glm,
  prob = 0.9,
  group_by_parameter = TRUE,
  facet_args = list(scales = "free", labeller = facet_names)
) +
  scale_colour_viridis_d(
    labels = c("Intercept", "Behavioural Risk Factors", "IMD Score", "Physiological Risk Factors", "Sigma")
  ) +
  theme_minimal(base_family = "sans", base_size = 12) +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    plot.margin = unit(c(0.5, 1, 1, 1), "cm")
  )
```

![](01-deprivation_files/figure-gfm/posterior-checks-2.png)

``` r
bayesplot::ppc_scatter_avg(
  deprivation_df$life_expectancy, life_expectancy_rep[subset, ]
)
```

![](01-deprivation_files/figure-gfm/posterior-checks-3.png)

### Estimated Parameter Values

``` r
bayestestR::hdi(
  life_expectancy_glm,
  ci = c(
    0.5, 0.75, 0.89, 0.95
  )
) %>%
  plot()
```

![](01-deprivation_files/figure-gfm/parameter-values-1.png)

``` r
bayestestR::map_estimate(
  life_expectancy_posterior
) %>%
  plot()
```

![](01-deprivation_files/figure-gfm/parameter-values-2.png)

## Explore Stan Model Using Shiny

``` r
# doesn't run in quarto doc

# rstanarm::launch_shinystan(life_expectancy_glm)
```
