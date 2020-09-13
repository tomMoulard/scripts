# Bookplit
A utility to split audio books using it's corresponding timestamp

# Author
[Luke Smith](lukesmith.xyz)

# How to use
You must provide a music file and a timestamp file:
```bash
./booksplit <audiofile> <timestamp file>
```

Where the timestamp file is formatted as follow:
```
00:00:00 Indroduction
00:01:01 bla bla bla

<hour>:<min>:<sec> <title>
```
