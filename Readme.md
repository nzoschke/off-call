# Off-Call - PagerDuty Utilities

Generate report of PagerDuty activity for a specific time range.

Usage:

```
$ cp .env.sample .env
$ bin/report
Summary for PXXXXXX,PYYYYYY from 2012-05-16 12:00:00 +0000 to 2012-05-23 15:23:52 +0000
+-----------------+-------+
| Key             | Count |
+-----------------+-------+
| Test incident   | 1     |
+-----------------+-------+
...

$ SERVICES=PZZZZZZ SINCE="Last Week" UNTIL=Now bin/report 
...
```



