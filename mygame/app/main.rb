def tick args

  defaults args if Kernel.tick_count == 0


  args.audio[:bg_music] ||= { input: 'sounds/nss_mus_battle2v2.ogg', looping: true, gain: get_music_volume(args) }
  start_layered_track(args, song: "nss_mus_battle1v2.ogg")

  case args.state.music_action
  when :fade_in
    fade_in_layered_track args
  when :fade_out
    fade_out_layered_track args
  else
    args.state.music_action = nil
  end

  args.state.logo_rect ||= { x: 576,
                             y: 200,
                             w: 128,
                             h: 101 }

  args.outputs.labels  << { x: 640,
                            y: 600,
                            text: 'Controls',
                            size_px: 30,
                            anchor_x: 0.5,
                            anchor_y: 0.5 }

  args.outputs.labels  << { x: 640,
                            y: 600,
                            text: 'Press I/O to fade the second track in/out',
                            size_px: 30,
                            anchor_x: 0.5,
                            anchor_y: 1.5 }
  args.outputs.labels  << { x: 640,
                            y: 600,
                            text: "W/S to increase/decrease music volume",
                            size_px: 30,
                            anchor_x: 0.5,
                            anchor_y: 2.5 }

  calc_inputs args

  args.outputs.labels  << { x: 640,
                            y: 480,
                            text: "Music Action: #{args.state.music_action}",
                            size_px: 25,
                            anchor_x: 0.5,
                            anchor_y: 0.5 }

  args.outputs.labels  << { x: 640,
                            y: 480,
                            text: "Music Volume: #{args.state.music_volume}",
                            size_px: 25,
                            anchor_x: 0.5,
                            anchor_y: 1.5 }
  args.outputs.labels  << { x: 640,
                            y: 480,
                            text: "BG1 Volume: #{args.audio[:bg_music].gain}",
                            size_px: 25,
                            anchor_x: 0.5,
                            anchor_y: 2.5 }

  args.outputs.labels  << { x: 640,
                            y: 480,
                            text: "BG2 Playing?: #{bg2_playing?(args)}",
                            size_px: 25,
                            anchor_x: 0.5,
                            anchor_y: 3.5 }

  args.outputs.labels  << { x: 640,
                            y: 480,
                            text: "BG2 Volume: #{args.audio[:bg_music2].gain}",
                            size_px: 25,
                            anchor_x: 0.5,
                            anchor_y: 4.5 }

  args.outputs.sprites << { x: args.state.logo_rect.x,
                            y: args.state.logo_rect.y,
                            w: args.state.logo_rect.w,
                            h: args.state.logo_rect.h,
                            path: 'dragonruby.png',
                            angle: Kernel.tick_count }

  args.outputs.labels  << { x: 640,
                            y: 380,
                            text: "Music used with permission. Created by Nick Rankin",
                            size_px: 25,
                            anchor_x: 0.5,
                            anchor_y: 5.5 }

  args.outputs.labels  << { x: 640,
                            y: 380,
                            text: "nicholasrankinmusic.com",
                            size_px: 25,
                            anchor_x: 0.5,
                            anchor_y: 6.5 }


  if args.inputs.keyboard.left
    args.state.logo_rect.x -= 10
  elsif args.inputs.keyboard.right
    args.state.logo_rect.x += 10
  end

  if args.inputs.keyboard.down
    args.state.logo_rect.y -= 10
  elsif args.inputs.keyboard.up
    args.state.logo_rect.y += 10
  end

  if args.state.logo_rect.x > 1280
    args.state.logo_rect.x = 0
  elsif args.state.logo_rect.x < 0
    args.state.logo_rect.x = 1280
  end

  if args.state.logo_rect.y > 720
    args.state.logo_rect.y = 0
  elsif args.state.logo_rect.y < 0
    args.state.logo_rect.y = 720
  end

  # debug
  wdid("Music Action: #{args.state.music_action}")
  wdid("Music Volume: #{args.state.music_volume}")
  wdid("Music Volume: #{get_music_volume(args)}")
  wdid("BG1 Gain: #{args.audio[:bg_music].gain}")
  wdid("BG2 Gain: #{args.audio[:bg_music2].gain}")
end

def wdid(value)
  $outputs.debug << value
end

def get_music_volume args
  args.state.music_volume/10
end


def calc_inputs args
  if args.inputs.keyboard.key_down.w and args.state.music_volume < 10
    args.state.music_volume += 1
    change_music_volume args
  end

  if args.inputs.keyboard.key_down.s and args.state.music_volume > 0
    args.state.music_volume -= 1
    change_music_volume args
  end

 if args.inputs.keyboard.key_down.i
   args.state.music_action = :fade_in
 end
 if args.inputs.keyboard.key_down.o
   args.state.music_action = :fade_out
 end
end
def defaults args
  args.state.music_volume = 3
  args.state.sfx_volume = 3
  args.state.music_action = nil
  args.state.bg2_playing = false
end

def bg2_playing? args
  args.state.bg2_playing
end
def play_sfx(args, file:)
  args.audio[:sfx] = { input: "sounds/#{file}.ogg", gain: args.state.sfx_volume/10 }
end

def change_music_volume args
  args.audio[:bg_music].gain = get_music_volume args #$music_volume

  if bg2_playing? args
      args.audio[:bg_music2].gain = get_music_volume args #$music_volume
  end
end

def change_sfx_volume args
  args.audio[:sfx].gain = args.state.sfx_volume/10
end

# could be useful if adding another layer so a 3 layer song
def start_layered_track(args, song: "nss_mus_battle2v2.ogg")
  args.audio[:bg_music2] ||= { input: "sounds/#{song}", looping: true, gain: 0.0 }
end

def fade_in_layered_track args
  # set so volume adjustments will trigger for this track
  args.state.bg2_playing = true
  if args.audio[:bg_music2] && args.audio[:bg_music2].gain < args.state.music_volume/10
    # increase secondary track volume until it matches the volume setting
    args.audio[:bg_music2].gain += 0.01
    args.audio[:bg_music2].gain = args.state.music_volume/10 if args.audio[:bg_music2].gain > args.state.music_volume/10
  end
  args.state.music_action = nil if args.audio[:bg_music2].gain == args.state.music_volume/10
end

def fade_out_layered_track args
  # set to not have volume adjustments trigger on this track
  args.state.bg2_playing = false
  if args.audio[:bg_music2] && args.audio[:bg_music2].gain > 0.0
    # decrease music volume until the layered track is silent
    args.audio[:bg_music2].gain -= 0.01
    args.audio[:bg_music2].gain = 0.0 if args.audio[:bg_music2].gain < 0.0 #  args.state.music_volume/10 if args.audio[:bg_music2].gain > args.state.music_volume/10
  end
  args.state.music_action = nil if args.audio[:bg_music2].gain == 0.0
end
