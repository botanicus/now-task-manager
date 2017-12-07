# `Task` format

This format is used to store **scheduled tasks**: tasks that will be done later
or in a certain context.

```
Tomorrow
- Buy milk.

Prague
- Pick up my shoes.
```

_There are detailed [unit specs](spec/pomodoro/parser) for the format._

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
- [started at 10:00] Print out invoices.
- Review GitHub issues.
- [11:40] Call with Sonia.

Lunch break (12 – 13)

Work for client 1 (13 – 17)
- Issue#87.

Evening (after 17)
- Free style meditation. #meditation
```

## Considered features

#### Nested time frames

Very often an action is interrupted by an other. If it takes 5 minutes, it's irrelevant to log it, but what if it took half of the afternoon?

```
Work for client 1 (13 – 17)
- Issue#87.

  Emergency (2 – 3:30)
  ✔ Extinguish fire in the living room.

- Task
```

_There are detailed [unit specs](spec/pomodoro/parser) for the format._
