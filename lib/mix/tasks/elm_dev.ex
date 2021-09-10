defmodule Mix.Tasks.ElmDev do
  @moduledoc "Compile elm files to js without optimizations"

  use Mix.Task

  def out(data) do
    IO.write(data)
  end

  @impl Mix.Task
  def run(args) do
    [input|output] = args
    Mix.Shell.cmd("elm make --output=#{output} #{input}", &out/1)
  end
end
