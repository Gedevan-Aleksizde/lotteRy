require(tidyverse)
require(magick)

# 回転アニメーション
make_rotate_animetion <- function(img, out = "Output.gif", sec = 1, angle = 360 * 2, fps = 20, rescale_parameter = "200x200"){
  # 再生時間 (sec) 内に何度回転 (angle) したいか.
  if(100 %% fps != 0) stop("gif の仕様上 fps は 100 を割り切れる数でないと無理")
  rpf <- angle / (sec * fps)
  tmpdir <- tempdir()
  angles <- seq(0, angle, rpf)
  if(is.character(img)){
    img <- image_read(img)
  }
  meta <- image_info(img)
  img <- image_scale(img, rescale_parameter)
  img <- image_extent(img, rescale_parameter, gravity = "center")
  for(r in unique(angles %% 360)){
    image_write(image = image_rotate(img, r), path = file.path(tmpdir, sprintf("frame%03d.png", r)))
  }
  image_write(
    image_animate(
      image_join(
        image_read(file.path(tmpdir, sprintf("frame%03d.png", angles %% 360)))
        ),
      fps = fps),
    out
    )
}
make_rotate_animetion("www/img/tokyor-logo.png", out = "www/img/waiting.gif", sec = 2)