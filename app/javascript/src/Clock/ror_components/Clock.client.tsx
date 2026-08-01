import React, { useState } from 'react';
import { useInterval } from 'usehooks-ts';

const Clock: React.FC = () => {
  const getCurrentTime = () => new Date().toLocaleString();
  const [clock, setClock] = useState<string>(getCurrentTime());

  useInterval(
    () => {
      setClock(getCurrentTime());
    }, 1000
  );

  return (
    <>
      <h1>{ clock }</h1>
    </>
  );
};

export default Clock;