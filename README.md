
<!-- README.md is generated from README.Rmd. Please edit that file -->
Shiny Usage Monitor
===================

Using Shiny Server Open Source? Want to see how many people are using your apps? This app allows you to monitor the number of users on your Shiny Server by continuously parsing through your server's logs and charting the data over time.


![demo](https://raw.githubusercontent.com/munoztd0/shiny-usage-monitor/master/img/screen.gif)


Know thyself
------------

Keeping track of the number of users on your Shiny Server is helpful for several reasons:

-   Identifies low-traffic periods (best times to push updates or restart the server)
-   Tells you if you need to pay more attention to scaling your apps (i.e. adjust server size, optimize slow apps)
-   Shows which apps are most popular

Basic architecture
------------------

1.  Deploy Shiny Server Open Source with one or more apps
2.  Continuously check your server's logs and save off data on the number of users on each app (`check_server.R` plus a cronjob)
3.  Use Shiny to display the data over time (`app.R`)

Installation
------------

##### 1: Add `app.R` and `server_status.R` into a new directory `/shiny-usage-monitor` in the same location as your shiny apps.

For example clone this repo into /srv/shiny-server/ such as that the code would be located in /srv/shiny-server/shiny-usage-monitor

##### 2. Install required packages for `app.R`

``` r
install.packages(c('shiny', 'tidyverse', 'lubridate', 'highcharter', 'this.path'))
```

But before check that everything works. From the root directory :

``` bash
sudo Rscript server_status.R
```

Now if everything run fine without error, you can:
``` bash
Rscript app.R
```

##### 3. Set up a cron to run `server_status.R` every minute. First, open up your crontab file as root:

Now we want to automate it.

The easiest way is to create a crontab as root (but you might want to allow sudo without password for some commands to avoid that, the two commands this script requires sudo privileges is netstat and lsof)

``` bash
sudo su
crontab -e
```

Then add this line to the end of the file (watch the path !)

``` bash
* * * * *  /usr/bin/Rscript /srv/shiny-server/server_status.R
```

Now you'll have real-time data on your users henceforth! You should now see a minute by minute graph for today's server usage in your `/shiny-usage-monitor` app. You can also check out `sysLoad.RData` to see the raw data.

``` r
load('sysLoad.RData')
head(Dat)
                     Time    PID  USER PR NI   VIRT    RES  SHR S CPU MEM     TIME usr             app
13335 2022-06-07 10:47:44 788293 shiny 20  0 433004 126424 5544 S 6.2 0.4 15:18.16   0 abuser-detection
13336 2022-06-07 10:50:33 788293 shiny 20  0 433004 126424 5544 S 6.2 0.4 15:18.25   0 abuser-detection
13337 2022-06-07 10:52:12 788293 shiny 20  0 433004 126424 5544 S 6.2 0.4 15:18.30   0 abuser-detection
13338 2022-07-08 01:04:23 2257544 shiny 20  0 1100996 570288 34160 S 6.2 0.9 0:41.21   6 trade-inspect
13339 2022-07-08 01:09:28 2257544 shiny 20  0 1100996 570288 34160 S 6.2 0.9 0:41.34   6 trade-inspect
13340 2022-07-08 01:14:33 2257544 shiny 20  0 1100996 570288 34160 S 6.2 0.9 0:41.49   6 trade-inspect
```

There you have it! You'll notice there's other information, notably CPU and Memory, in the data that could also be useful to track over time.


