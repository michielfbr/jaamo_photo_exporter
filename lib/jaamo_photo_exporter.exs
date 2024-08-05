defmodule JaamoPhotoExporter do
  @moduledoc false
  def run() do
    Mix.install([{:floki, "~> 0.36.2"}])

    {:ok, html} =
      System.get_env("INPUT_FILE", "input/photos.html")
      |> File.read!()
      |> Floki.parse_document()

    [{"span", [], [page_title]}] = Floki.find(html, "span")
    base_folder = "output/#{page_title}"
    File.mkdir_p(base_folder)
end

JaamoPhotoExporter.run()
