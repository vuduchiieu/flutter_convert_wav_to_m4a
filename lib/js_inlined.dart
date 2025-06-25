const String ffmpegJsCode = r"""
if (typeof window.ffmpegInstance === "undefined") {
  let ffmpeg;

  window.convertWavToM4a = async function (
    wavBytesBase64,
    inputFileName = "input.wav",
    callback
  ) {
    try {
      if (!window.FFmpeg) {
        throw new Error("FFmpeg not loaded");
      }

      const { createFFmpeg, fetchFile } = FFmpeg;

      if (!ffmpeg) {
        ffmpeg = createFFmpeg({ log: true });
      }

      if (!ffmpeg.isLoaded()) {
        try {
          await ffmpeg.load();
        } catch (error) {
          console.log("ffmpeg.load()", error);
        }
      }

      window.ffmpegInstance = ffmpeg;

      const wavBytes = Uint8Array.from(atob(wavBytesBase64), (c) =>
        c.charCodeAt(0)
      );


      ffmpeg.FS("writeFile", inputFileName, wavBytes);

      const outputFileName = inputFileName.replace(/\.\w+$/, ".m4a");

      await ffmpeg.run(
        "-i",
        inputFileName,
        "-c:a",
        "aac",
        "-b:a",
        "128k",
        outputFileName
      );

      console.log("6");

      const m4aBytes = ffmpeg.FS("readFile", outputFileName);

      console.log("7");

      const m4aBase64 = btoa(String.fromCharCode(...m4aBytes));

      console.log("8");

      callback(m4aBase64);
    } catch (error) {
      console.log("catch error", error);

      callback(null);
    }
  };
}


""";
