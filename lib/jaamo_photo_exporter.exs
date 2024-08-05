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
            {file_no + 1, current_date}
        end
      end)
  end

  defp get_date_from_item({"div", [{"class", "col-12 font_semi_bold text-start"}], [date]}) do
    [day, month, year] = date |> String.trim() |> String.split(" ")
    {:ok, "#{year}_#{map_month(month)}_#{day}"}
  end

  defp get_date_from_item(_), do: {:error, :no_date}

  defp map_month("januari"), do: "01"
  defp map_month("februari"), do: "02"
  defp map_month("maart"), do: "03"
  defp map_month("april"), do: "04"
  defp map_month("mei"), do: "05"
  defp map_month("juni"), do: "06"
  defp map_month("juli"), do: "07"
  defp map_month("augustus"), do: "08"
  defp map_month("september"), do: "09"
  defp map_month("oktober"), do: "10"
  defp map_month("november"), do: "11"
  defp map_month("december"), do: "12"
  defp map_month(month), do: "#{month}"

  defp print(input), do: [input] |> IO.ANSI.format() |> IO.puts()
  defp print(input, formatting), do: [formatting, input] |> IO.ANSI.format() |> IO.puts()
end

JaamoPhotoExporter.run()
