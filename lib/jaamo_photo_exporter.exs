defmodule JaamoPhotoExporter do
  @moduledoc false
  def run() do
    print("Jaamo image export", :blue_background)

    print("Installing dependencies")
    Mix.install([{:floki, "~> 0.36.2"}, {:req, "~> 0.5.6"}])

    print("Reading input file")

    {:ok, html} =
      System.get_env("INPUT_FILE", "input/photos.html")
      |> File.read!()
      |> Floki.parse_document()

    print("Creating output folder")
    [{"span", [], [page_title]}] = Floki.find(html, "span")
    base_folder = "output/#{page_title}"
    File.mkdir_p(base_folder)

    print("Starting export for: #{page_title}", :green)

    [{"div", [{"class", "image_gallery d-flex flex-wrap mx-2"}], gallery_items}] =
      Floki.find(html, ".image_gallery")

    print("Saving images...")

    {_file_no, _current_date} =
      Enum.reduce(gallery_items, {1, ""}, fn item, {file_no, current_date} ->
        case get_date_from_item(item) do
          {:ok, new_date} ->
            print("-- #{new_date} --", :green)
            {1, new_date}

          _ ->
            download_and_save_file(item, "#{base_folder}/#{current_date} #{file_no}")
            {file_no + 1, current_date}
        end
      end)
  end

  defp get_date_from_item({"div", [{"class", "col-12 font_semi_bold text-start"}], [date]}) do
    [day, month, year] = date |> String.trim() |> String.split(" ")
    {:ok, "#{year}_#{map_month(month)}_#{day}"}
  end

  defp get_date_from_item(_), do: {:error, :no_date}

  defp download_and_save_file(
         {"div", [{"class", "image_canvas col-3 pe-2 pb-2"}], [contents]},
         file_name_base
       ) do
    [url] = Floki.attribute(contents, "href")

    with {:ok, image_data} <- download_image(url) do
      {title, caption} = Floki.find(contents, "p") |> Floki.text() |> parse_caption()
      title = if title, do: " #{title}", else: ""

      write_file("#{file_name_base}#{title}.jpeg", image_data)

      if caption, do: write_file("#{file_name_base}.txt", caption)
    end
  end

  defp write_file(filename, data) do
    if File.exists?(filename) do
      raise "File allready exists, can't overwrite: #{filename}"
    else
      print(filename)
      File.write(filename, data)
    end
  end

  defp download_and_save_file(_, _), do: :no_file

  defp download_image(url) do
    case Req.get(url) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {_, error} ->
        print("Image download failed", :red)
        {:error, :no_image}
    end
  end

  defp parse_caption(""), do: {nil, nil}

  defp parse_caption(caption) do
    formatted_caption = format_caption(caption)

    if String.length(formatted_caption) < 120 do
      {formatted_caption, nil}
    else
      title =
        formatted_caption
        |> String.split(". ")
        |> hd
        |> format_caption()

      {title, caption}
    end
  end

  defp format_caption(text) do
    text
    |> String.replace("\n", " ")
    |> String.replace("\r", " ")
    |> String.replace(["    ", "   ", "  "], " ")
    |> String.trim_trailing(".")
    |> String.trim()
  end

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
