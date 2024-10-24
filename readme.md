# فضای کیوسک من
مرورگر Chromium را با یک صفحه کلید مجازی داخلی در Docker در محیط گرافیکی حداقلی روی سرور تمیز Ubuntu 16.04 LTS به طور خودکار اجرا می کند.
### مزایای پیاده سازی:
- محیط حداقل در حال نصب است. (OpenBox، Docker و Chromium)
- شروع خودکار هنگام راه اندازی سیستم
- امنیت سیستم - کاربر در مرورگر فقط محیط داخل کانتینر را می بیند و نه سیستمی را که از آن راه اندازی شده است.
### نصب و راه اندازی
> git clone https://github.com/laspavel/mykioskspace
> cd mykioskspace
> ./build.sh https://mystartpage.com
در کد، https://mystartpage.com صفحه شروع راه اندازی کیوسک است.
