# `Today` format

This format is used for tasks that are being worked on today.

```
Morning routine (7:50 – 9:20)
✔ Headspace. #meditation
✘ Go swimming. #exercise
  Reason: Some clever excuse.
✔ Eat breakfast.
✔ [20] Spanish flashcards. #learning

Admin (9:20 – 12)
✔ [9:20-10:00] Inbox 0.
  I should allocate more time to it from now on.

  Some more comment line 1
  Some more comment line 2
- [started at 10:00] Print out invoices.
- Review GitHub issues.
- [11:40] Call with Sonia.

Lunch break (12 – 13)

Work for client 1 (13 – 17)
- Issue#87.

Evening (after 17)
- Free style meditation. #meditation
```

## Metadata

Metadata are indented lines following a task.

There can be either lines, subtasks or key value pairs or a combination of either.

### Lines

```
I should allocate more time to it from now on.

Some more comment line 1.
Some more comment line 2.
```

This will turn into:

```ruby
[
  "I should allocate more time to it from now on.",
  "Some more comment line 1. Some more comment line 2."
]
```

### Key-value pairs

```
- [8:25-8:41] Research EU residency permit:
  Link: http://www.migrant.info.pl/temporary-residence-permit.html, http://www.migrant.info.pl/residence-card.html
  Outcome: This is what I need.
  Next: Apply for http://www.migrant.info.pl/temporary-residence-permit.html # -> This makes the task.
  Review: Upon my return from CZ/ES. # -> This makes a headline.

- [10:09-10:20] Push the code from Cloud9 to GH and clone it from my mac.
  Skipped: SSH keys issues, I requested it to be researched.

- [11:42-12:20] Clean up the flat, find my MasterCard.
  Comment: It took me a good while to find the card. # VNORENY.
    I have to clean up the mess and keep it clean!

- Headspace.
  Skipped: Instead of meditating, I wrote a command to play the next HS episode and, to remember them. I tend to forget which episode I'm on.

- Millennium: pick up EUR.
  Postponed: Queue too long.

- [11:31-11:41] Review my moleskine to see whether I need to take it with me.
  Outcome: I don't need to take it.

✔ Inquire about why the payment failed.
  Waiting for: Response.
  Review: Tomorrow.

- [9:51-9:59] Inquire about why the payment failed.
  Review: tomorrow.
```

### Subtasks

```
- [9:37-9:51] Plan the CZ/ES trip and make the reservations for PRG.
  ✔ Book accommodation in PRG.
  - Ping Macarena.
```

## Considered features

#### Nested time frames

Very often an action is interrupted by an other. If it takes 5 minutes, it's irrelevant to log it, but what if it took half of the afternoon?

NOTE: http://kschiess.github.io/parslet/parser.html last to chapters explain how to create the recursion.

```
Work for client 1 (13 – 17)
- Issue#87.

  Emergency (2 – 3:30)
  ✔ Extinguish fire in the living room.

- Task
```

_There are detailed [unit specs](spec/pomodoro/parser) for the format._
