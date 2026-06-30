#!/bin/bash

# CONSTANTS
WALLPAPER_SOURCE=("/home/yxki/Media/Wallpapers"/*.jpg)
WALLPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"
LAPTOP_MONITOR="eDP-1"
MONITOR="DP-1"
WALLPAPER_CURRENT="$HOME/.config/current/currentWallpaper"

#find current wallpaper index
#check if index is equal to max index
#if less than max index increment
#if equal to max index reset to 0
#write to the hyprpaper conf file

# FIND THE CURRENT WALLPAPER INDEX
IFS1=' ' read path1 <<<"$(head -n 3 $WALLPAPER_CONFIG)"
#IFS2=' ' read path2 <<<"$(head -n 9 $WALLPAPER_CONFIG)"
#IFS3=' ' read path3 <<<"$(head -n 15 $WALLPAPER_CONFIG)"

current_wallpaper_index=0
for i in "${!WALLPAPER_SOURCE[@]}"; do
  echo ${WALLPAPER_SOURCE[$i]}
  [ "${WALLPAPER_SOURCE[$i]}" = "$path1" ] && current_wallpaper_index=$i
done

# CHECK IF INDEX IS EQUAL TO MAX INDEX
count=${#WALLPAPER_SOURCE[@]}
max_index=$((count - 1))

next_wallpaper_index=0
if [ "$current_wallpaper_index" -eq "$max_index" ]; then
  echo "reset wallpaper folder array"
  next_wallpaper_index=0
else
  echo "increment wallpaper folder array"
  next_wallpaper_index=$((current_wallpaper_index + 1))
fi

echo $max_index
echo $current_wallpaper_index
echo $next_wallpaper_index

# WRITE TO HYPRPAPER CONF FILE

next_wallpaper="${WALLPAPER_SOURCE[$next_wallpaper_index]}"

cat <<EOF >"$WALLPAPER_CONFIG"
wallpaper {
  monitor = $LAPTOP_MONITOR
  path = $next_wallpaper
  fit_mode= cover
}

wallpaper {
  monitor = $MONITOR
  path = $next_wallpaper
  fit_mode = cover
}

wallpaper {
  monitor = 
  path = $next_wallpaper
  fit_mode = cover
}

splash = true
EOF

# GENERATE COLORS
hellwal -i "$next_wallpaper"

# RESET HYPRPAPER
pkill hyprpaper
sleep 0.2
hyprpaper &

# RESET HYPRLAND
#~/.config/scripts/hyprlandColors.sh
hyprctl reload
pkill waybar
waybar &
