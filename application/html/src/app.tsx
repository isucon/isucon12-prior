import { AppBar, Button, Container, CssBaseline, makeStyles, Toolbar, Typography } from '@material-ui/core';
import { VFC } from "react";
import { Route, Routes, useNavigate } from 'react-router'
import { LockOpen, PersonAdd } from '@material-ui/icons'
import { RootPage } from './rootPage';
import { SignupPage } from './signupPage';
import { LoginPage } from './loginPage';
import { useAppContext } from './context';
import { SchedulePage } from './schedulePage';

const useStyles = makeStyles(() => ({
  title: {
    flexGrow: 1,
  }
}))

export const App: VFC = () => {
  const classes = useStyles();
  const navigate = useNavigate();
  const { user, logout } = useAppContext();

  return (
    <>
      <CssBaseline />
      <AppBar position="static">
        <Container>
          <Toolbar>
            <Typography variant="h6" className={classes.title}>ISUCON 12 Prior</Typography>

            { user ? (
              <Button color="inherit" onClick={() => logout()}>{user.nickname}</Button>
            ): (
              <>
                <Button color="inherit" onClick={() => navigate('/signup')} startIcon={<PersonAdd />}>Signup</Button>
                <Button color="inherit" onClick={() => navigate('/login')} startIcon={<LockOpen />}>Login</Button>
              </>
            )}
          </Toolbar>
        </Container>
      </AppBar>
      <Routes>
        <Route path="/" element={<RootPage />} />
        <Route path="/signup" element={<SignupPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/schedules/:id" element={<SchedulePage />} />
      </Routes>
    </>
  );
}
