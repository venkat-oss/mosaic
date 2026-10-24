# Aggregate Functions

SQL aggregate function expressions. Aggregate detection in SQL fragments includes the DuckDB 2.0 functions `combine_aggr`, `decimal_average`, `lttb`, and `variant_group_object`. These names can be used through [`sql`](./expressions#sql) or `AggregateNode`.

## Native aggregate preview

The temporary `@uwdata/mosaic-sql/native` entry provides these high-level
aggregate helpers over Polyglot's semantic expression variants. Derived
aggregates retain `.distinct()`, `.where()` and `.argOrder()`; `.window()`,
`.partitionby()`, `.orderby()` and `.frame()` construct windowed versions.
These methods return new handles, leaving the original aggregate unchanged.

``` js
import { Query, gt, sum } from '@uwdata/mosaic-sql/native';

const positive = sum('amount').where(gt('amount', 0));
const query = Query.from('sales').select({ total: positive });
```

Native DuckDB coordinators can preaggregate compatible queries using sufficient
statistics, including mean-centered variance and regression calculations.
Distinct or ordered aggregates that cannot be combined safely run directly.
See the [coordinator options](../core/coordinator#constructor).

Cross-dialect compilation raises an error when a semantic conversion is
unsupported. DuckDB discrete quantile, argmax/min and correlation/slope edge
semantics are among the PostgreSQL restrictions; successful DuckDB execution
does not imply support for another target.
Portable string aggregation requires known text semantics and a constant,
non-null separator. The compiler supplies DuckDB's default comma when omitted.

## AggregateNode {#aggregate-node}

The `AggregateNode` class represents a SQL AST node for an aggregate function call.
Users should not need to instantiate `AggregateNode` instances directly, but instead should use aggregate function methods such as [`count()`](#count), [`sum()`](#sum), _etc_.

### distinct

`AggregateNode.distinct()`

Returns a new AggregateNode instance that applies the aggregation over distinct values only.

### where

`AggregateNode.where(filter)`

Returns a new AggregateNode instance filtered according to a Boolean-valied _filter_ expression.

### window

`AggregateNode.window()`

Returns a windowed version of this aggregate function as a new [WindowNode](./window-functions#window-node) instance.

### partitionby

`AggregateNode.partitionby(...expressions)`

Provide one or more _expressions_ by which to partition a windowed version of this aggregate function and returns a new [WindowNode](./window-functions#window-node) instance.

### orderby

`AggregateNode.orderby(...expressions)`

Provide one or more _expressions_ by which to sort a windowed version of this aggregate function and returns a new [WindowNode](./window-functions#window-node) instance.

### frame

`AggregateNode.frame(definition)`

Return a windowed version of this aggregate with the given frame definition.
Use `frameRows(extent)`, `frameRange(extent)` or `frameGroups(extent)` to construct
the definition. See [window frames](./window-functions#frame).

## count

`count()`

Create an aggregate function that counts the number of records.

## avg

`avg(expression)`

Create an aggregate function that calculates the average of the input _expression_.

## mad

`mad(expression)`

Create an aggregate function that calculates the median absolute deviation (MAD) of the input _expression_.

## max

`max(expression)`

Create an aggregate function that calculates the maximum of the input _expression_.

## min

`min(expression)`

Create an aggregate function that calculates the minimum of the input _expression_.

## sum

`sum(expression)`

Create an aggregate function that calculates the sum of the input _expression_.

## product

`product(expression)`

Create an aggregate function that calculates the product of the input _expression_.

## geomean

`geomean(expression)`

Create an aggregate function that calculates the geometric mean of the input _expression_.

## median

`median(expression)`

Create an aggregate function that calculates the average of the input _expression_.

## quantile

`quantile(expression, p)`

Create an aggregate function that calculates the _p_-th quantile of the input _expression_.
For example, _p_ = 0.5 computes the median, while 0.25 computes the lower inter-quartile range boundary.

## mode

`mode(expression)`

Create an aggregate function that calculates the mode of the input _expression_.

## variance

`variance(expression)`

Create an aggregate function that calculates the sample variance of the input _expression_.

## stddev

`stddev(expression)`

Create an aggregate function that calculates the sample standard deviation of the input _expression_.

## skewness

`skewness(expression)`

Create an aggregate function that calculates the skewness of the input _expression_.

## kurtosis

`kurtosis(expression)`

Create an aggregate function that calculates the kurtosis of the input _expression_.

## entropy

`entropy(expression)`

Create an aggregate function that calculates the entropy of the input _expression_.

## varPop

`varPop(expression)`

Create an aggregate function that calculates the population variance of the input _expression_.

## stddevPop

`stddevPop(expression)`

Create an aggregate function that calculates the population standard deviation of the input _expression_.

## corr

`corr(a, b)`

Create an aggregate function that calculates the correlation between the input expressions _a_ and _b_.

## covarPop

`covarPop(a, b)`

Create an aggregate function that calculates the population covariance between the input expressions _a_ and _b_.

## regrIntercept

`regrIntercept(y, x)`

Create an aggregate function that returns the intercept of the fitted linear regression model that predicts the target expression _y_ based on the predictor expression _x_.

## regrSlope

`regrSlope(y, x)`

Create an aggregate function that returns the slope of the fitted linear regression model that predicts the target expression _y_ based on the predictor expression _x_.

## regrCount

`regrCount(y, x)`

Create an aggregate function that returns the count of non-null values used to fit the linear regression model that predicts the target expression _y_ based on the predictor expression _x_.

## regrR2

`regrR2(y, x)`

Create an aggregate function that returns the R^2 value of the fitted linear regression model that predicts the target expression _y_ based on the predictor expression _x_.

## regrSXX

`regrSXX(y, x)`

Create an aggregate function that returns the SXX value (`regrCount(y, x) * varPop(x)`) of the fitted linear regression model that predicts the target expression _y_ based on the predictor expression _x_.

## regrSYY

`regrSYY(y, x)`

Create an aggregate function that returns the SYY value (`regrCount(y, x) * varPop(y)`) of the fitted linear regression model that predicts the target expression _y_ based on the predictor expression _x_.

## regrSXY

`regrSXY(y, x)`

Create an aggregate function that returns the SXY (`regrCount(y, x) * covarPop(y, x)`) value of the fitted linear regression model that predicts the target expression _y_ based on the predictor expression _x_.

## regrAvgX

`regrAvgX(y, x)`

Create an aggregate function that returns the average x value of the data used to fit the linear regression model that predicts the target expression _y_ based on the predictor expression _x_.

## regrAvgY

`regrAvgY(y, x)`

Create an aggregate function that returns the average x value of the data used to fit the linear regression model that predicts the target expression _y_ based on the predictor expression _x_.

## first

`first(expression)`

Create an aggregate function that calculates the first observed value of the input _expression_.

## last

`last(expression)`

Create an aggregate function that calculates the last observed value of the input _expression_.

## argmax

`argmax(arg, value)`

Create an aggregate function that returns the expression _arg_ corresponding to the maximum value of the expression _value_.

## argmin

`argmin(arg, value)`

Create an aggregate function that returns the expression _arg_ corresponding to the minimum value of the expression _value_.

## stringAgg

`stringAgg(expression)`

Create an aggregate function that returns the string concatenation of the input _expression_ values.

## arrayAgg

`arrayAgg(expression)`

Create an aggregate function that returns a list of the input _expression_ values.
