class JsInlined {
  static String ffmpegJsCode = r"""
let ffmpegInstance;

async function initFFmpegOnce() {
  if (ffmpegInstance && ffmpegInstance.isLoaded()) return ffmpegInstance;

  if (!window.FFmpeg) {
    throw new Error("FFmpeg not loaded");
  }

  const { createFFmpeg } = FFmpeg;
  ffmpegInstance = createFFmpeg({ log: false });

  try {
    await ffmpegInstance.load();
  } catch (error) {
    console.error("ffmpeg.load() failed", error);
    throw error;
  }

  return ffmpegInstance;
}

window.convertWavToM4a = async function (
  wavBytesBase64,
  inputFileName = "input.wav",
  callback
) {


  try {
    console.error("window.crossOriginIsolated", window.crossOriginIsolated);
    const ffmpeg = await initFFmpegOnce();
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

    const m4aBytes = ffmpeg.FS("readFile", outputFileName);

    const m4aBase64 = btoa(
      Array.from(m4aBytes)
        .map((b) => String.fromCharCode(b))
        .join("")
    );
    callback(m4aBase64);
  } catch (error) {
    console.error("catch.load()", error);
    callback(null);
  }
};

""";
}
