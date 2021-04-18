# Fish shell functions relating to system power management

function ssn --wraps systemctl --description "Shuts down the system immediately."
    systemctl --no-wall poweroff
end

function srn --wraps systemctl --description "Reboots the system immediately."
    systemctl --no-wall reboot
end

function sus --wraps systemctl --description "Suspends the system immediately."
    systemctl suspend
end

function hib --wraps systemctl --description "Hibernates the system immediately."
    systemctl hibernate
end
