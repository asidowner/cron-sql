# cron-sql
store cron schedule in sql and use it to filter dates!

## The problem
I need to record the meeting schedule of parties we are dealing with into an sql database - can't use any other type of database. I need to represent all the crazy ways user's can define a schedule.

## The solution
[Cron Expression](https://en.wikipedia.org/wiki/Cron) is a way of representing scheduling information for `cron jobs`. Combined with [Quartz](http://www.quartz-scheduler.org/) extensions you get a pretty solid way of representing most if not all of the common ways of scheduling. Armed with that, if we can find a good way of representing and filtering our schedules in the database in this format then we should be good.

`Cron-sql` provides a set of functions that allow matching a date to a `cron` expression. It consists of the following functions:

1. `cron_isvalueinrange(varchar(10), int)` a function that checks is a value is a member of a cron range e.g. 4-10,1-5 etc
2. `cron_isvaluemember(varchar(70), int)` a function that checks if a value is a member of a cron list e.g. 1,2,3,4 or 5,6,8,15
3. `cron_isbasicmatch(varchar(2000), @value int)` a function that matches the `*, - and ,`. This function has a dependency on 2 other functions 
4. `cron_matchesdayofmonth(varchar(70),datetime)` a function that builds on *function (3)* above adding support for **L**(*last day of the month*) extension
5. `cron_matchesmonth(varchar(70),datetime)` a function that builds on *function (3)* above and adds support for abbreviated month names i.e. `JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC`
6. `cron_matchesdayofweek(varchar(70,datetime)` a function that builds on *function (3)* above that adds support for **L**(*last day of the month*) and **#**(*nth day of the week*) extensions.
7. `cron_ismatch(@minute, @hour, @dayofmonth, @month, @dayofweek, @year, @date)` a function that matches a split cron function to a date,
8. `cron_split(varchar(2000))` a function that takes a cron expression as string and returns a table with each component part.

an expression `* * * * * *` is matched as:

1. Minute: `cron_isbasicmatch`
2. Hour: `cron_isbasicmatch`
3. Day Of Month: `cron_matchesdayofmonth`
4. Month: `cron_matchesmonth`
5. Day Of Week: `cron_matchesdayofweek`
6. Year: `cron_isbasicmatch`

In the db, I don't need to save the expression as a single piece of text to save me from the hustle of splitting the string every time we query.

## How is the performance?
Good enough :). Tested against all days for 2100 years since 1800 and did it in 20 seconds however for a year I was done in under 1 second.

If I have a significantly large data set e.g. the dates are narrow but the candidates are a large set then I'll pre-calculate the matches to improve performance of the application.

Queries more often than not will be a table scan; combine with something to narrow the rows that could match.

