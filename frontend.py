import logging

import pykka
from mopidy import core

logger = logging.getLogger(__name__)


class RaspberryGPIOFrontend(pykka.ThreadingActor, core.CoreListener):
    def __init__(self, config, core):
        super().__init__()
        import RPi.GPIO as GPIO

        self.core = core
        self.config = config["raspberry-gpio"]
        self.pin_settings = {}

        GPIO.setwarnings(False)
        GPIO.setmode(GPIO.BCM)

        # Iterate through any bcmN pins in the config
        # and set them up as inputs with edge detection
        for key in self.config:
            if key.startswith("bcm"):
                pin = int(key.replace("bcm", ""))
                settings = self.config[key]
                if settings is None:
                    continue

                pull = GPIO.PUD_UP
                edge = GPIO.FALLING
                if settings.active == "active_high":
                    pull = GPIO.PUD_DOWN
                    edge = GPIO.RISING

                GPIO.setup(pin, GPIO.IN, pull_up_down=pull)

                GPIO.add_event_detect(
                    pin,
                    edge,
                    callback=self.gpio_event,
                    bouncetime=settings.bouncetime,
                )

                self.pin_settings[pin] = settings

    def gpio_event(self, pin):
        settings = self.pin_settings[pin]
        self.dispatch_input(settings.event)

    def dispatch_input(self, event):
        handler_name = f"handle_{event}"
        try:
            getattr(self, handler_name)()
        except AttributeError:
            raise RuntimeError(
                f"Could not find input handler for event: {event}"
            )

    def handle_play_pause(self):
        if self.core.playback.get_state().get() == core.PlaybackState.PLAYING:
            self.core.playback.pause()
        else:
            self.core.playback.play()

    def handle_next(self):
        self.core.playback.next()

    def handle_prev(self):
        self.core.playback.previous()

    def handle_volume_up(self):
        volume = self.core.mixer.get_volume().get()
        volume += 1
        volume = min(volume, 100)
        self.core.mixer.set_volume(volume)

    def handle_volume_down(self):
        volume = self.core.mixer.get_volume().get()
        volume -= 1
        volume = max(volume, 0)
        self.core.mixer.set_volume(volume)
