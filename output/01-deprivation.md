The Relationship between Deprivation & Health Outcomes
================
Paul Johnson
2022-09-07

<script src="01-deprivation_files/libs/kePrint-0.0.1/kePrint.js"></script>
<link href="01-deprivation_files/libs/lightable-0.0.1/lightable.css" rel="stylesheet" />


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
  kableExtra::kbl() %>%
  kableExtra::kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    fixed_thead = T
  )
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">   </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> mean </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> median </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> sd </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> min </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> max </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> life_expectancy </td>
   <td style="text-align:right;"> 81.148214 </td>
   <td style="text-align:right;"> 81.15723 </td>
   <td style="text-align:right;"> 1.554173 </td>
   <td style="text-align:right;"> 76.85814 </td>
   <td style="text-align:right;"> 85.22368 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mortality </td>
   <td style="text-align:right;"> 193.020921 </td>
   <td style="text-align:right;"> 189.99839 </td>
   <td style="text-align:right;"> 39.418309 </td>
   <td style="text-align:right;"> 118.90000 </td>
   <td style="text-align:right;"> 328.37085 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> imd_score </td>
   <td style="text-align:right;"> 23.174205 </td>
   <td style="text-align:right;"> 22.83750 </td>
   <td style="text-align:right;"> 8.045406 </td>
   <td style="text-align:right;"> 5.84600 </td>
   <td style="text-align:right;"> 45.03900 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> imd_decile </td>
   <td style="text-align:right;"> 5.445206 </td>
   <td style="text-align:right;"> 5.00000 </td>
   <td style="text-align:right;"> 2.828502 </td>
   <td style="text-align:right;"> 1.00000 </td>
   <td style="text-align:right;"> 10.00000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> physiological_risk_factors </td>
   <td style="text-align:right;"> 99.684589 </td>
   <td style="text-align:right;"> 98.70000 </td>
   <td style="text-align:right;"> 9.717607 </td>
   <td style="text-align:right;"> 80.20000 </td>
   <td style="text-align:right;"> 125.90000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> behavioural_risk_factors </td>
   <td style="text-align:right;"> 99.361301 </td>
   <td style="text-align:right;"> 100.60000 </td>
   <td style="text-align:right;"> 8.611750 </td>
   <td style="text-align:right;"> 72.40000 </td>
   <td style="text-align:right;"> 118.30000 </td>
  </tr>
</tbody>
</table>

``` r
deprivation_df %>%
  ggplot(aes(life_expectancy, imd_score)) +
  geom_point()
```

![](01-deprivation_files/figure-gfm/imd-score-eda-1.png)

``` r
deprivation_df %>%
  ggplot(aes(life_expectancy, physiological_risk_factors)) +
  geom_point()
```

![](01-deprivation_files/figure-gfm/health-index-eda-1.png)

``` r
deprivation_df %>%
  ggplot(aes(life_expectancy, behavioural_risk_factors)) +
  geom_point()
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
  kableExtra::kbl() %>%
  kableExtra::kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    fixed_thead = T
  )
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Parameter </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> imd_score </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> behavioural_risk_factors </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> physiological_risk_factors </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> life_expectancy </td>
   <td style="text-align:right;"> -0.8380433 </td>
   <td style="text-align:right;"> 0.9059915 </td>
   <td style="text-align:right;"> 0.5637379 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> physiological_risk_factors </td>
   <td style="text-align:right;"> -0.3777696 </td>
   <td style="text-align:right;"> 0.5407540 </td>
   <td style="text-align:right;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> behavioural_risk_factors </td>
   <td style="text-align:right;"> -0.8416980 </td>
   <td style="text-align:right;">  </td>
   <td style="text-align:right;">  </td>
  </tr>
</tbody>
</table>

There are strong correlations between life expectancy and the three
independent variables, however, the correlation between IMD score and
the two risk factor variables is also relatively strong, and in the case
of behavioural risk factors, it is very strong. This could be an issue.

``` r
deprivation_df %>%
  ggplot(aes(imd_score, physiological_risk_factors)) +
  geom_point()
```

![](01-deprivation_files/figure-gfm/correlation-eda-1.png)

``` r
deprivation_df %>%
  ggplot(aes(imd_score, behavioural_risk_factors)) +
  geom_point()
```

![](01-deprivation_files/figure-gfm/correlation-eda-2.png)

``` r
deprivation_df %>%
  mutate(imd_decile = as.factor(imd_decile)) %>%
  ggplot(aes(physiological_risk_factors, imd_decile)) +
  ggridges::geom_density_ridges()
```

![](01-deprivation_files/figure-gfm/correlation-eda-3.png)

``` r
deprivation_df %>%
  mutate(imd_decile = as.factor(imd_decile)) %>%
  ggplot(aes(behavioural_risk_factors, imd_decile)) +
  ggridges::geom_density_ridges()
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

sjPlot::tab_model(life_expectancy_ols)
```

<table style="border-collapse:collapse; border:none;">
<tr>
<th style="border-top: double; text-align:center; font-style:normal; font-weight:bold; padding:0.2cm;  text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:normal; font-weight:bold; padding:0.2cm; ">life expectancy</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">81.22</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">81.15&nbsp;&ndash;&nbsp;81.29</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">imd transformed</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.07</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.08&nbsp;&ndash;&nbsp;-0.05</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">physiological transformed</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02&nbsp;&ndash;&nbsp;0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">behavioural transformed</td>
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
  kableExtra::kbl() %>%
  kableExtra::kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    fixed_thead = T
  )
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Parameter </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Prior_Distribution </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> Prior_Location </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> Prior_Scale </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:left;"> normal </td>
   <td style="text-align:right;"> 80 </td>
   <td style="text-align:right;"> 1.00 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> imd_transformed </td>
   <td style="text-align:left;"> normal </td>
   <td style="text-align:right;"> -1 </td>
   <td style="text-align:right;"> 0.25 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> physiological_transformed </td>
   <td style="text-align:left;"> normal </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.50 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> behavioural_transformed </td>
   <td style="text-align:left;"> normal </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.25 </td>
  </tr>
</tbody>
</table>

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
sjPlot::tab_model(life_expectancy_glm)
```

<table style="border-collapse:collapse; border:none;">
<tr>
<th style="border-top: double; text-align:center; font-style:normal; font-weight:bold; padding:0.2cm;  text-align:left; ">&nbsp;</th>
<th colspan="2" style="border-top: double; text-align:center; font-style:normal; font-weight:bold; padding:0.2cm; ">life expectancy</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">CI (95%)</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">81.22</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">81.15&nbsp;&ndash;&nbsp;81.29</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">imd transformed</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.07</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.08&nbsp;&ndash;&nbsp;-0.05</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">physiological transformed</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02&nbsp;&ndash;&nbsp;0.03</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">behavioural transformed</td>
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
  kableExtra::kbl() %>%
  kableExtra::kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    fixed_thead = T
  )
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Parameter </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> Sensitivity_Median </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> imd_transformed </td>
   <td style="text-align:right;"> 3.516621 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> physiological_transformed </td>
   <td style="text-align:right;"> 5.990901 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> behavioural_transformed </td>
   <td style="text-align:right;"> 3.511873 </td>
  </tr>
</tbody>
</table>

``` r
# bayestestR::diagnostic_posterior(life_expectancy_glm)

life_expectancy_priors %>%
  bayestestR::diagnostic_posterior() %>%
  kableExtra::kbl() %>%
  kableExtra::kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    fixed_thead = T
  )
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Parameter </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> Rhat </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ESS </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> MCSE </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> (Intercept) </td>
   <td style="text-align:right;"> 0.9998913 </td>
   <td style="text-align:right;"> 4621.268 </td>
   <td style="text-align:right;"> 0.0150862 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> behavioural_transformed </td>
   <td style="text-align:right;"> 1.0003332 </td>
   <td style="text-align:right;"> 4291.445 </td>
   <td style="text-align:right;"> 0.0039489 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> imd_transformed </td>
   <td style="text-align:right;"> 1.0000625 </td>
   <td style="text-align:right;"> 4580.788 </td>
   <td style="text-align:right;"> 0.0037278 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> physiological_transformed </td>
   <td style="text-align:right;"> 1.0003704 </td>
   <td style="text-align:right;"> 4456.207 </td>
   <td style="text-align:right;"> 0.0073042 </td>
  </tr>
</tbody>
</table>

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
posterior_vs_prior(
  life_expectancy_glm,
  prob = 0.9,
  group_by_parameter = TRUE,
  facet_args = list(scales = "free")
) +
  scale_colour_viridis_d()
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
