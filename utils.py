class PeriodicEvent(object):
    def __init__(self, interval, func):
        self.interval = interval
        self.func = func
        self.terminate = threading.Event()

    def _signals_install(self, func):
        for sig in [signal.SIGINT, signal.SIGTERM]:
            signal.signal(sig, func)

    def _signal_handler(self, signum, frame):
        self.terminate.set()

    def run(self):
        self._signals_install(self._signal_handler)
        while not self.terminate.is_set():
            self.func()
            self.terminate.wait(self.interval)
        self._signals_install(signal.SIG_DFL)