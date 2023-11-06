# ExPoll

# Installing / Getting started
## Setup

To run this project, you will need to install:

* Elixir - 1.15.0-otp-26
* Erlang - 26.0.1

Which is already added to the .tool_versions file.

## Start server
To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server
`

## Navigate
To Create/Vote a poll, you have to:

  * Visit [`localhost:4000/login`](http://localhost:4000/login) from your browser.
    <img width="1064" alt="1 user-login" src="https://github.com/rathorevk/ex_poll/assets/146935994/e9015d6c-08f5-477b-bc64-91f1374ab678">
  * Enter a username and press **Join** button to login.
    <img width="1281" alt="3 polls page" src="https://github.com/rathorevk/ex_poll/assets/146935994/2b5c314a-e2b8-4054-8a76-c7096471427f">

  * Use **New Poll** button to create a poll, please input the poll header/text and 4 options and press **Save** button to submit the poll.
    <img width="1062" alt="4 new poll" src="https://github.com/rathorevk/ex_poll/assets/146935994/68f02bba-868b-4d66-bac4-d751a616ad3b">

  * The new poll will be published to the list of polls where user can Vote by clicking on any one of four option:
    <img width="1275" alt="5 poll ready for vote" src="https://github.com/rathorevk/ex_poll/assets/146935994/ac6f045f-8c57-477a-adfb-90be66198ae2">

    **Note** - You can vote only once in a poll.
  
  * You can see result of the poll and it will be updated whenever any other user submit the vote for this poll:
    <img width="1135" alt="6 after submitting vote" src="https://github.com/rathorevk/ex_poll/assets/146935994/82856312-136c-45e5-814c-308c07d80785">


  * Create more poll and participates in other's polls
    <img width="1118" alt="7  add more poll and vote" src="https://github.com/rathorevk/ex_poll/assets/146935994/8cd7e79e-3f9a-4505-bfc7-45997f900a2d">


## Tests

To run the tests for this project, simply run in your terminal:

```shell
mix test
```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
