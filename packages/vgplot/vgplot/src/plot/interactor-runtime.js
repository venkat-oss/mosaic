export function interactor(InteractorClass, options) {
  return plot => {
    const mark = plot.marks[plot.marks.length - 1];
    plot.addInteractor(new InteractorClass(mark, options));
  };
}
