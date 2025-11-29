const GREEN = Bun.color("green", "ansi");
const RED = Bun.color("red", "ansi");
const CYAN = Bun.color("cyan", "ansi");
const NC = "\x1b[0m";

String.prototype.green = function () {
  return `${GREEN}${this}${NC}`;
};

String.prototype.red = function () {
  return `${RED}${this}${NC}`;
};

String.prototype.cyan = function () {
  return `${CYAN}${this}${NC}`;
};

String.prototype.color = function (color) {
  const ansiColor = Bun.color(color, "ansi");

  return `${ansiColor}${this}${NC}`;
};
