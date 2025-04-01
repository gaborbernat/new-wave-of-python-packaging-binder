use pyo3::prelude::{PyModule, PyModuleMethods};
use pyo3::{pyfunction, pymodule, wrap_pyfunction, Bound, PyResult};

#[cfg(test)]
mod tests;

#[must_use]
#[pyfunction]
pub fn first_n(count: usize) -> Vec<u32> {
    let mut result: Vec<u32> = Vec::new();
    let mut at = 2;
    while result.len() < count {
        let mut divided = false;
        for &divisor in result.iter() {
            if at % divisor == 0 {
                divided = true;
                break;
            }
        }
        if !divided {
            result.push(at);
        }
        at += 1;
    }
    result
}

#[pymodule]
#[pyo3(name = "_lib")]
pub fn _lib(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(first_n, m)?)?;
    Ok(())
}
