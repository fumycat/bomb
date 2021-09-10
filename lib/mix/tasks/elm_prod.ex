defmodule Mix.Tasks.ElmProd do
  @moduledoc "Compile elm files to js with optimizations and minify"

  use Mix.Task

  def out(data) do
    IO.write(data)
  end

  @impl Mix.Task
  def run(args) do
    [input, output] = args
    min_file = String.replace(output, ".js", ".min.js")
    Mix.Shell.cmd("elm make --optimize --output=#{output} #{input}", &out/1)

    Mix.Shell.cmd(
      "uglifyjs #{output} --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output #{min_file}",
      &out/1
    )
  end
end
