import React from 'react';

interface DeadlineProps {
  totalRemainingTime: number;
}

const Deadline: React.FC<DeadlineProps> = ({ totalRemainingTime }: DeadlineProps) => {
  const deadline = () => new Date(new Date().getTime() + totalRemainingTime * 1000).toLocaleString();

  return (
    <>
      { deadline() }
    </>
  );
};

export default Deadline;