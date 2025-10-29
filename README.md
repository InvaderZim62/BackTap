# BackTap

"Back Tap" is a feature in iOS 14+ and iPhone 8+.  It can be use to trigger events on the phone, but is not available in code for app development.

I created this app to demonstrate how you can detect taps on the back iPhone in code using the z-accelerometer.

Here is a plot of z-acceleration (z-accel) versus time.  I tapped the back of the phone twice with the screen facing up, and twice with the screen facing down.  As you can see, the nominal z-accel is -1 for the screen facing up, and +1 for the screen facing down.

<img width="450" height="208" alt="Accel plot" src="https://github.com/user-attachments/assets/e81cbd40-83a5-481d-98a3-8c7de8e0f047" />

In order to get the nominal z-accel to be zero for all orientations, I passed the samples through a washout filter (aka high-pass filter).  The washout filter approximates the rate of change of z-accel.  If the acceleration isn't changing, the output is zero.

Here is a plot of z-accel and filtered z-accel, while tapping the back twice facing up and twice facing down.  The filter amplifies the slightest motion, but keeps the z-accel centered near zero.

<img width="450" height="208" alt="Filtered accel plot" src="https://github.com/user-attachments/assets/3d28648d-e77e-40c1-b5f8-6e5e94dddce1" />
