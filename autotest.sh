#!/usr/bin/env bash

mkdir -p autotest_logs
for p in $(apt list | cut -d"/" -f1); do
	if echo $p | grep -qo "Listing\.\.\.\|apt\|coreutils\|busybox\|bash\|dpkg\|yes"; then continue; fi
	echo "-----> Installing $p"
	yes | apt install $p
	for bin in $(dpkg -L $p | grep "/usr/bin/"); do
		echo "-----> Executing $(basename $bin)"
		fname=autotest_logs/${p}-$(date -u)-$(basename $bin).log
		timeout \
			--signal=KILL 3 \
			$bin 2> "$fname"
		if echo $? | grep -qo "134\|139"; then
			echo "-----> Error for binary $bin, and has been stored to $fname."
		else
			echo "-----> $(basename $bin) is OK."
			rm "$fname"
		fi
		killall -9 $bin || killall -9 $(basename $bin)
	done

	# Uncommenting this line could lead into accidental system packages deletion
	# and therefore is not recommended to be enabled.
	# apt autoremove -y $p
done
