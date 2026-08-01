import React, { useState } from 'react';
import { useCounter, useInterval } from 'usehooks-ts';

interface TimerProps {
  initTaskTime: number;
  initTimerFlag: boolean;
  elapsedTaskTime: number;
}

const Timer: React.FC<TimerProps> = ( {initTaskTime, initTimerFlag, elapsedTaskTime}: TimerProps ) => {
  const [taskTime, setTaskTime] = useState<number>(initTaskTime);
  const [timerFlag, settimerFlag] = useState<boolean>(initTimerFlag);
  const { count, increment } = useCounter(0);

  const makeTimeString = ( timestamp: number ) => {
    const hourNumber = Math.trunc(timestamp / (60 * 60));
    const minuteNumber = Math.abs(Math.trunc(timestamp / 60 % 60));
    const secondNumber = Math.abs(timestamp % 60);

    const timeString = [hourNumber, minuteNumber, secondNumber].map(t => String(t).padStart(2, '0'));

    if ( timestamp >= 0 ) {
      return timeString.join(':');
    } else {
      return `-${timeString.join(':')}`;
    }
  }

  const makeTaskTimeString = ( taskTime: number ) => {
    return makeTimeString(taskTime);
  }

  const makeRemainingTimeString = ( taskTime: number ) => {
    if ( timerFlag ) {
      useInterval(
        () => {
          increment();
        }, 1000
      );
    }
    return makeTimeString(taskTime - count - elapsedTaskTime);
  }

  return (
    <>
      { makeRemainingTimeString(taskTime) } / { makeTaskTimeString(taskTime) }
    </>
  );
};

export default Timer;