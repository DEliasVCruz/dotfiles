export const fatal = (message, error) => {
  console.log(message);
  console.log(error.red());
  process.exit(1);
};

export const sleep = async (time) => {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve();
    }, time);
  });
};
