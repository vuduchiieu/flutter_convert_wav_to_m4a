if (typeof window.ffmpegInstance === "undefined") {
  let ffmpeg;

  window.convertWavToM4a = async function (
    wavBytesBase64,
    inputFileName = "input.wav",
    callback
  ) {
    try {
      console.log(wavBytesBase64);
      console.log(inputFileName);

      if (!window.FFmpeg) {
        throw new Error("FFmpeg not loaded");
      }

      const { createFFmpeg, fetchFile } = FFmpeg;

      if (!ffmpeg) {
        ffmpeg = createFFmpeg({ log: false, threads: false });
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

      console.log("wavBytes");

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

      const m4aBytes = ffmpeg.FS("readFile", outputFileName);

      const m4aBase64 = btoa(String.fromCharCode(...m4aBytes));

      callback(m4aBase64);
    } catch (error) {
      console.log("catch error", error);
      callback(null);
    }
  };
}
