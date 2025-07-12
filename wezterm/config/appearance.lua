local gpu_adapters = require('utils.gpu-adapter')
local colors = require('colors.custom')

return {
   --- 渲染器
   max_fps = 120,
   front_end = 'OpenGL',
   prefer_egl = true,
   -- webgpu_power_preference = 'HighPerformance',
   -- webgpu_preferred_adapter = gpu_adapters:pick_best(),
   -- webgpu_preferred_adapter = gpu_adapters:pick_manual('Dx12', 'IntegratedGpu'),
   -- webgpu_preferred_adapter = gpu_adapters:pick_manual('Gl', 'Other'),

   -- cursor

   -- color scheme
   colors = colors,

   -- background
   window_background_opacity = 0.9,

   -- scrollbar
   enable_scroll_bar = false,

   -- tab bar
   enable_tab_bar = false,

   -- window
   window_decorations = 'RESIZE', --- 是否显示标题栏
   window_padding = {
      left = 20,
      right = 20,
      top = 10,
      bottom = 10,
   },
   adjust_window_size_when_changing_font_size = false,
   window_close_confirmation = 'NeverPrompt',
   window_frame = {
      active_titlebar_bg = '#090909',
      -- font = fonts.font,
      -- font_size = fonts.font_size,
   },
   -- inactive_pane_hsb = {
   --    saturation = 0.9,
   --    brightness = 0.65,
   -- },
   inactive_pane_hsb = {
      saturation = 0.9, -- 饱和度
      brightness = 0.7, -- 亮度
   },

   -- 铃声响起时改变光标颜色
   visual_bell = {
      fade_in_function = 'EaseIn',
      fade_in_duration_ms = 250,
      fade_out_function = 'EaseOut',
      fade_out_duration_ms = 250,
      target = 'CursorColor',
   },
}
