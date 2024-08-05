# Jaamo photo exporter

A script to download all photos from the Jaamo app at once.
Built since Jaamo lacks this functionability, and saving 900+ photos and then adding the date and caption, one by one would be a pain in the \*ss.

The script will iterate through app's html to download every photo and store it, using it's date and description. Longer descriptions will be stored in a separate text file.

### Run the script

The script can be run from cli.

1. Install elixir: https://elixir-lang.org/install.html
2. Save the html input as `photos.html` in the `input` folder: see [Input](#input)
3. Run the script: `elixir jaamo_photo_exporter.exs`
   If the input is located in another file, pass the path to it like this:
   `INPUT_FILE=input/example.html elixir jaamo_photo_exporter.exs`
4. Output can be found in the `output` foler

Give it a try: `INPUT_FILE=input/example.html elixir jaamo_photo_exporter.exs`

> **NOTE:**
> Jaamo source images are stored at AWS. The path to them, retrieved from the html page, contains an auth token which is only valid for 10 minutes.
> Therefore the script should be run immediately after refreshing and saving the html page.

### Input

Input is the plain html of the `Photo's` page in the webapp, found at `https://[organisation].jaamo.nl/ouders/children/[child_id]/photos`. Or by navigating to `Account` > `Profielen` > `Alle foto's`

1. Navigate to the page mentioned above
2. Open your browser's dev tools
3. Navigate to `Sources` tab
4. Save the entire page as a html file by right clicking `photos`

![Jaamo screenshot](screenshot.png "Jaamo screenshot")
