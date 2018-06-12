This format is used to store **scheduled tasks**: tasks that will be done later
or in a certain context.

```
Tomorrow
- Buy milk. #errands
- [9:20] Call with Mike.

Prague
- Pick up my shoes. #errands
```

# Currently unsupported

- **Labels**. Labels allow us to match tasks with _named_ time frames.
  See [#8](https://github.com/botanicus/now-task-manager/issues/8).

```
- ADM: Catch up with Eva.
```

# Intentionally unsupported

- **Comments**. I want to keep the format simple and the task file small.
  Every time there was something like comments, the file bloated uncontrollably.
- **Task formatting**. Task is a string, it doesn't recognise any structures within.
  Therefore, anything you can fit in to a line will be the task body. So you can
  put anything that {Pomodoro::Formats::Today} supports such as scheduled times
  and tags.

_For more details about the format see
{https://github.com/botanicus/now-task-manager/blob/master/spec/pomodoro/formats/scheduled/parser/parser_spec.rb parser_spec.rb}._
