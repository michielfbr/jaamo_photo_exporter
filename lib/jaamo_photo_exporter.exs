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

    [{"div", [{"class", "image_gallery d-flex flex-wrap mx-2"}], gallery_items}] =
      Floki.find(html, ".image_gallery")

    {_file_no, _current_date} =
      Enum.reduce(gallery_items, {1, ""}, fn item, {file_no, current_date} ->
        case get_date_from_item(item) do
          {:ok, new_date} ->
            {1, new_date}

          _ ->
            :ok
        end
      end)
end

JaamoPhotoExporter.run()
