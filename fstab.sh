source_fstab_file="./custom/fstab"
target_fstab_file="/etc/fstab"
if [ ! -f "$source_fstab_file" ]; then
	echo "Error: Source fstab file '$source_fstab_file' not found."
	exit 1
fi
if [ ! -f "$target_fstab_file" ]; then
	echo "Error: Target fstab file '$target_fstab_file' not found."
	exit 1
fi

temp_target_mount_points_file=$(mktemp)

trap 'rm -f "$temp_target_mount_points_file"' EXIT
echo "Loading mount points from target fstab: $target_fstab_file ..."
awk 'NF > 1 && $1 !~ /^#/ {print $2}' "$target_fstab_file" > "$temp_target_mount_points_file"
while IFS= read -r line_from_source; do
	if [[ "$line_from_source" =~ ^\s*# ]] || [[ -z "$line_from_source" ]]; then
		continue
	fi

	read -r _discard_first mount_point_to_check _discard_rest <<< "$line_from_source"

	if [ -z "$mount_point_to_check" ]; then
		echo "Warning: Skipping malformed line in source_fstab (no mount point): '$line_from_source'"
		continue
	fi

	if grep -qFx "$mount_point_to_check" "$temp_target_mount_points_file"; then
		echo "skipping: $line_from_source"
	else
		echo "$line_from_source" >> /etc/fstab
	fi
done < "$source_fstab_file"
