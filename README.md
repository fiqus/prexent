# Prexent
[![Hex pm](http://img.shields.io/hexpm/v/prexent.svg?style=flat)](https://hex.pm/packages/prexent)

> ### Markdown |> HTML |> code |> run |> edit
> Create fast, live and beautiful presentations from Markdown powered by Phoenix LiveView.

This is the Spawnfest 2019 project by [Fiqus](https://github.com/fiqus) team.

A HTML presentations generator from markdown files with the ability to *run* and *edit* live elixir code (and other bunch of languages).
Once you create a prexent, the dependency will be installed on top of Phoenix and LiveView, gaining all its powerfull features.

Install the mix archive, create presentations quicky on the fly, edit markdown, include your code and prexent!

## Pre-requisites
  * `Elixir` 1.7 or later
  * `Erlang/OTP` 18 or later

## Create a presentation
Install the mix archive installer from Hex:

    $ mix archive.install hex prexent_new 0.1.1

Or create it from an unreleased version:

    $ cd installer
    $ mix do archive.build, archive.install

The installer is installed globally for your elixir version and with this you will be able to create multiple presentations quickly.

Create a new presentation in any directory:

    $ mix prexent.new nice_talk

The installer will prompt you to confirm installing all the dependecies, `prexent` will be installed!

    $ cd nice_talk
    $ mix deps.get

This mix task will create the project structure and a `slides.md` with demo Markdown, feel free to edit it!

Then, run prexent:

    $ mix prexent

If you change the file name you can optionally pass that to the task:

    $ mix present source_file.md

## Prexent commands

Customize your presentations, add prexent commands wherever you want in your markdown file:

#### Live code
    !code code/my_function.exs

#### Header, footer, css..
    !header Fiqus
    !footer Slider
    !custom_css demo_files/custom.css

#### Background image
Global background

    !global_background /background.jpg

Background for a specific slide

    !slide_background /background.jpg

#### Include other markdown files
    !include partial.md

Enjoy!