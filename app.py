from flask import Flask, render_template, request, redirect, url_for, flash, session
import pyodbc
from datetime import datetime, timedelta
from functools import wraps
from datetime import date

app = Flask(__name__)
app.secret_key = 'bloodbank_secret_key_2024'


# ----------------------------
# DATABASE CONNECTION
# ----------------------------
def get_db_connection():
    connection_string = 'DRIVER={SQL Server};SERVER=DESKTOP-4J5DF41;DATABASE=bloodBankSystem;Trusted_Connection=yes;'

    conn = pyodbc.connect(connection_string)
    return conn

def get_db_connection_ngo():
    connection_string = 'DRIVER={SQL Server};SERVER=DESKTOP-4J5DF41;DATABASE=bloodBankNGO;Trusted_Connection=yes;'

    conn = pyodbc.connect(connection_string)
    return conn

# ---------------------------------------------------------
# HELPER FUNCTIONS
# ---------------------------------------------------------
def rows_to_dict_list(cursor):
    """Convert SQL rows to list of dictionaries"""
    columns = [column[0] for column in cursor.description]
    results = []
    for row in cursor.fetchall():
        results.append(dict(zip(columns, row)))
    return results


def execute_query(query, params=None, fetch=True):
    """Execute SQL query with error handling"""
    conn = get_db_connection()
    if not conn:
        return None

    try:
        cursor = conn.cursor()
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)

        if fetch:
            result = rows_to_dict_list(cursor)
        else:
            conn.commit()
            result = cursor.rowcount

        cursor.close()
        conn.close()
        return result
    except Exception as e:
        print(f"❌ Query error: {e}")
        if conn:
            conn.close()
        return None


# ---------------------------------------------------------
# AUTHENTICATION DECORATOR
# ---------------------------------------------------------
def login_required(f):
    """Decorator to protect routes - login required"""

    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            flash('Please login to access this page!', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)

    return decorated_function


def role_required(required_role):
    """Decorator to check user role"""

    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if 'user_role' not in session or session['user_role'] != required_role:
                flash(f'Access denied! {required_role.capitalize()} role required.', 'danger')
                return redirect(url_for('dashboard'))
            return f(*args, **kwargs)

        return decorated_function

    return decorator


# ---------------------------------------------------------
# LOGIN/LOGOUT ROUTES
# ---------------------------------------------------------

@app.route('/')
def home():
    """Home page - redirects to login or dashboard"""
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))


@app.route('/login', methods=['GET', 'POST'])
def login():
    """Login page"""
    if 'user_id' in session:
        flash('You are already logged in!', 'info')
        return redirect(url_for('dashboard'))

    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '').strip()

        if not username or not password:
            flash('Please enter both username and password!', 'danger')
            return render_template('login.html')

        try:
            user = execute_query("""
                SELECT userID, username, userRole, staffID, doctorID, plainPassword
                FROM UserLogin
                WHERE username = ? AND plainPassword = ?
            """, (username, password))

            if user and len(user) > 0:
                session['user_id'] = user[0]['userID']
                session['username'] = user[0]['username']
                session['user_role'] = user[0]['userRole']
                session['linked_id'] = user[0]['staffID'] or user[0]['doctorID']

                execute_query(
                    "UPDATE UserLogin SET lastLogin = GETDATE() WHERE userID = ?",
                    (user[0]['userID'],),
                    fetch=False
                )

                if user[0]['userRole'] == 'staff':
                    details = execute_query(
                        "SELECT staffName, staffRole, centerID FROM Staff WHERE staffID = ?",
                        (session['linked_id'],)
                    )
                    if details:
                        session['full_name'] = details[0]['staffName']
                        session['role_title'] = details[0]['staffRole']
                        session['center_id'] = details[0]['centerID']
                elif user[0]['userRole'] == 'doctor':
                    details = execute_query(
                        "SELECT doctorName, specialization FROM Doctor WHERE doctorID = ?",
                        (session['linked_id'],)
                    )
                    if details:
                        session['full_name'] = details[0]['doctorName']
                        session['role_title'] = details[0]['specialization']
                elif user[0]['userRole'] == 'admin':
                    session['full_name'] = 'Administrator'
                    session['role_title'] = 'System Admin'

                flash(f'Welcome {session.get("full_name", username)}!', 'success')
                return redirect(url_for('dashboard'))
            else:
                flash('Invalid username or password!', 'danger')

        except Exception as e:
            print(f"Login error: {e}")
            flash(f'Login error: {str(e)}', 'danger')

    return render_template('login.html')


@app.route('/logout')
def logout():
    """Logout user"""
    session.clear()
    flash('You have been logged out successfully.', 'info')
    return redirect(url_for('login'))


# ---------------------------------------------------------
# DASHBOARD
# ---------------------------------------------------------

@app.route('/dashboard')
@login_required
def dashboard():
    """Main dashboard"""
    try:
        stats = {}
        today_stats = execute_query("""
            SELECT
                ISNULL((SELECT COUNT(*) FROM Donation WHERE CAST(donationDate AS DATE) = CAST(GETDATE() AS DATE)), 0) AS DonationsToday,
                ISNULL((SELECT COUNT(*) FROM BloodRequest WHERE CAST(requestDate AS DATE) = CAST(GETDATE() AS DATE)), 0) AS RequestsToday
        """)

        if today_stats:
            stats = today_stats[0]

        donor_count = execute_query("SELECT COUNT(*) AS donor_count FROM Donor")
        d_count = donor_count[0]['donor_count'] if donor_count else 0

        blood_count = execute_query("SELECT COUNT(*) AS blood_count FROM BloodUnit WHERE status='stored'")
        b_count = blood_count[0]['blood_count'] if blood_count else 0

        alerts = execute_query("""
            SELECT TOP 5 bu.bloodUnitID, bg.groupName, bu.expiryDate, c.bloodCenterName
            FROM BloodUnit bu
            JOIN BloodGroup bg ON bu.bgID = bg.bgID
            JOIN BloodBankCenter c ON bu.centerID = c.centerID
            WHERE bu.status = 'stored'
              AND bu.expiryDate BETWEEN GETDATE() AND DATEADD(DAY, 7, GETDATE())
            ORDER BY bu.expiryDate
        """) or []

        return render_template('index.html',
                               d_count=d_count,
                               b_count=b_count,
                               stats=stats,
                               alerts=alerts)

    except Exception as e:
        print(f"Dashboard error: {e}")
        flash(f'Error loading dashboard: {str(e)}', 'danger')
        return render_template('index.html', d_count=0, b_count=0, stats={}, alerts=[])


# ---------------------------------------------------------
# INVENTORY
# ---------------------------------------------------------

@app.route('/inventory')
@login_required
def inventory():
    """Live blood inventory"""
    try:
        inventory_data = execute_query("SELECT * FROM v_LiveInventory ORDER BY bloodCenterName, BloodGroup")
        if not inventory_data:
            inventory_data = []
        return render_template('inventory.html', inventory=inventory_data)
    except Exception as e:
        flash(f'Error loading inventory: {str(e)}', 'danger')
        return render_template('inventory.html', inventory=[])


# ---------------------------------------------------------
# DONOR MANAGEMENT
# ---------------------------------------------------------

@app.route('/donors', methods=['GET', 'POST'])
@login_required
def donors():
    """Donor management"""
    try:
        if request.method == 'POST':
            search_term = request.form.get('phone', '').strip()
            if search_term:
                donors_data = execute_query("""
                    SELECT d.donorID, d.name, d.contactNo, d.donorEmail, bg.groupName, d.address, d.lastDonationDate
                    FROM Donor d
                    JOIN BloodGroup bg ON d.bgID = bg.bgID
                    WHERE d.contactNo LIKE ?
                       OR d.donorEmail LIKE ?
                       OR d.name LIKE ?
                    ORDER BY d.donorID DESC
                """, (f'%{search_term}%', f'%{search_term}%', f'%{search_term}%'))
            else:
                donors_data = execute_query("""
                    SELECT TOP 50 d.donorID, d.name, d.contactNo, d.donorEmail, bg.groupName, d.address, d.lastDonationDate
                    FROM Donor d
                    JOIN BloodGroup bg ON d.bgID = bg.bgID
                    ORDER BY d.donorID DESC
                """)
        else:
            donors_data = execute_query("""
                SELECT TOP 50 d.donorID, d.name, d.contactNo, d.donorEmail, bg.groupName, d.address, d.lastDonationDate
                FROM Donor d
                JOIN BloodGroup bg ON d.bgID = bg.bgID
                ORDER BY d.donorID DESC
            """)

        if not donors_data:
            donors_data = []

        return render_template('donors.html', donors=donors_data)

    except Exception as e:
        flash(f'Error loading donors: {str(e)}', 'danger')
        return render_template('donors.html', donors=[])


@app.route('/donor/<int:id>')
@login_required
def donor_detail(id):
    """Donor details page"""
    try:
        donor_info = execute_query("""
            SELECT d.*, bg.groupName, g.genderName,
                   CASE 
                       WHEN CHARINDEX(',', REVERSE(d.address)) > 0 
                       THEN LTRIM(REVERSE(LEFT(REVERSE(d.address), CHARINDEX(',', REVERSE(d.address)) - 1)))
                       ELSE d.address
                   END AS city
            FROM Donor d
            JOIN BloodGroup bg ON d.bgID = bg.bgID
            JOIN GenderType g ON d.genderID = g.genderID
            WHERE donorID = ?
        """, (id,))

        if not donor_info:
            flash('Donor not found!', 'danger')
            return redirect(url_for('donors'))

        eligibility = execute_query("""
            SELECT
                CASE
                    WHEN lastDonationDate IS NULL THEN 'Eligible'
                    WHEN DATEDIFF(DAY, lastDonationDate, GETDATE()) >= 90 THEN 'Eligible'
                    ELSE 'Not Eligible - Wait ' + CAST(90 - DATEDIFF(DAY, lastDonationDate, GETDATE()) AS VARCHAR) + ' days'
                END AS EligibilityStatus
            FROM Donor
            WHERE donorID = ?
        """, (id,))

        status = eligibility[0]['EligibilityStatus'] if eligibility else 'Unknown'

        history = execute_query("""
            SELECT do.donationDate, do.amountINml, s.staffName AS CollectedBy
            FROM Donation do
            JOIN Staff s ON do.collectedByStaffID = s.staffID
            WHERE do.donorID = ?
            ORDER BY do.donationDate DESC
        """, (id,)) or []

        return render_template('donor_detail.html', donor=donor_info[0], status=status, history=history)

    except Exception as e:
        flash(f'Error loading donor details: {str(e)}', 'danger')
        return redirect(url_for('donors'))
@app.route('/add_donor', methods=['GET', 'POST'])
@login_required
def add_donor():
    """Add new donor - Step 1: Basic Information"""
    if request.method == 'POST':
        try:
            # Store donor info in session for screening
            session['pending_donor'] = {
                'name': request.form['name'],
                'dob': request.form['dob'],
                'gender': request.form['gender'],
                'bg': request.form['bg'],
                'contact': request.form['contact'],
                'email': request.form['email'],
                'city': request.form['city'],
                'address': request.form['address']
            }

            return redirect(url_for('donor_screening'))

        except Exception as e:
            flash(f'Error: {str(e)}', 'danger')

    # GET request - load form data
    try:
        bgs = execute_query("SELECT * FROM BloodGroup") or []
        genders = execute_query("SELECT * FROM GenderType") or []
        return render_template('add_donor.html', bgs=bgs, genders=genders)
    except Exception as e:
        flash(f'Error loading form data: {str(e)}', 'danger')
        return render_template('add_donor.html', bgs=[], genders=[])


@app.route('/donor_screening', methods=['GET', 'POST'])
@login_required
def donor_screening():
    """Step 2: Health Screening"""
    if 'pending_donor' not in session:
        flash('No pending donor registration found!', 'warning')
        return redirect(url_for('add_donor'))

    donor = session['pending_donor']

    if request.method == 'POST':
        admit = request.form.get('admit')

        if admit == 'yes':
            try:
                # Register the donor
                full_address = f"{donor['address']}, {donor['city']}"

                conn = get_db_connection()
                cursor = conn.cursor()

                # Insert donor
                cursor.execute("""
                    INSERT INTO Donor (name, dateOfBirth, genderID, bgID, contactNo, donorEmail, address, lastDonationDate)
                    OUTPUT INSERTED.donorID
                    VALUES (?, ?, ?, ?, ?, ?, ?, NULL)
                """, (donor['name'], donor['dob'], donor['gender'], donor['bg'],
                      donor['contact'], donor['email'], full_address))

                donor_id = cursor.fetchone()[0]
                conn.commit()
                cursor.close()
                conn.close()

                # Store donor_id for donation prompt
                session['new_donor_id'] = donor_id
                session['new_donor_name'] = donor['name']

                # Clear pending donor
                session.pop('pending_donor', None)

                return render_template('donor_screening.html',
                                       donor=donor,
                                       success=True,
                                       message='✅ Health screening passed! Donor registered successfully.')

            except Exception as e:
                return render_template('donor_screening.html',
                                       donor=donor,
                                       success=False,
                                       message=f'❌ Registration failed: {str(e)}')
        else:
            # Clear session
            session.pop('pending_donor', None)
            return render_template('donor_screening.html',
                                   donor=donor,
                                   success=False,
                                   message='❌ Health screening not completed. Please complete all tests before donating.')

    # GET request - show screening modal
    return render_template('donor_screening.html', donor=donor)


@app.route('/donation_prompt', methods=['GET', 'POST'])
@login_required
def donation_prompt():
    """Step 3: Ask if donor wants to donate now"""
    if 'new_donor_id' not in session:
        return redirect(url_for('donors'))

    if request.method == 'POST':
        wants_donate = request.form.get('donate')
        donor_id = session['new_donor_id']

        # Clear session data
        session.pop('new_donor_id', None)
        session.pop('new_donor_name', None)

        if wants_donate == 'yes':
            return redirect(url_for('add_donation', donor_id=donor_id))
        else:
            flash('Donor registered successfully!', 'success')
            return redirect(url_for('donors'))

    donor_name = session.get('new_donor_name', 'Donor')
    return render_template('donation_prompt.html', donor_name=donor_name)


@app.route('/add_donation/<int:donor_id>', methods=['GET', 'POST'])
@login_required
def add_donation(donor_id):
    """Add donation for a donor"""
    try:
        # Get donor info
        donor_info = execute_query("""
            SELECT d.*, bg.groupName
            FROM Donor d
            JOIN BloodGroup bg ON d.bgID = bg.bgID
            WHERE d.donorID = ?
        """, (donor_id,))

        if not donor_info:
            flash('Donor not found!', 'danger')
            return redirect(url_for('donors'))

        donor = donor_info[0]

        if request.method == 'POST':
            try:
                amount = request.form['amount']
                donation_type = request.form['donation_type']
                center_id = request.form['center_id']
                staff_id = request.form['staff_id']
                donation_date = request.form.get('donation_date', date.today())

                conn = get_db_connection()
                cursor = conn.cursor()

                # FIXED: Insert donation WITHOUT OUTPUT clause to avoid trigger conflict
                cursor.execute("""
                    INSERT INTO Donation (donorID, screeningID, donationTypeID, donationDate, amountINml, collectedByStaffID)
                    VALUES (?, NULL, ?, ?, ?, ?)
                """, (donor_id, donation_type, donation_date, amount, staff_id))

                # Get the last inserted donation ID
                cursor.execute("SELECT @@IDENTITY AS donationID")
                result = cursor.fetchone()
                donation_id = int(result[0])

                # Create blood unit
                expiry_date = datetime.strptime(str(donation_date), '%Y-%m-%d') + timedelta(days=90)

                cursor.execute("""
                    INSERT INTO BloodUnit (donationID, bgID, centerID, storageDate, expiryDate, latestResult, status)
                    VALUES (?, ?, ?, ?, ?, 'Clear', 'stored')
                """, (donation_id, donor['bgID'], center_id, donation_date, expiry_date))

                conn.commit()
                cursor.close()
                conn.close()

                flash(f'✅ Donation of {amount}ml recorded successfully!', 'success')
                return redirect(url_for('donors'))

            except Exception as e:
                if conn:
                    conn.rollback()
                flash(f'Error recording donation: {str(e)}', 'danger')
                print(f"Donation error: {e}")

        # GET request - load form data
        centers = execute_query("SELECT centerID, bloodCenterName FROM BloodBankCenter") or []
        staff = execute_query("SELECT staffID, staffName FROM Staff") or []
        donation_types = execute_query("SELECT donationTypeID, donationTypeName FROM DonationType") or []

        return render_template('add_donation.html',
                               donor=donor,
                               centers=centers,
                               staff=staff,
                               donation_types=donation_types,
                               today=date.today())

    except Exception as e:
        flash(f'Error: {str(e)}', 'danger')
        return redirect(url_for('donors'))
# ---------------------------------------------------------
# DIRECT DONATION FOR EXISTING DONORS
# ---------------------------------------------------------

@app.route('/donate', methods=['GET', 'POST'])
@login_required
def direct_donation():
    """Direct donation page for existing donors"""
    if request.method == 'POST':
        email = request.form.get('email', '').strip()

        if not email:
            flash('Please enter your email address!', 'warning')
            return render_template('direct_donation.html')

        try:
            # Check if donor exists
            donor_info = execute_query("""
                SELECT d.*, bg.groupName
                FROM Donor d
                JOIN BloodGroup bg ON d.bgID = bg.bgID
                WHERE d.donorEmail = ?
            """, (email,))

            if not donor_info:
                flash('❌ Email not found! Please register as a new donor first.', 'danger')
                return render_template('direct_donation.html')

            donor = donor_info[0]
            donor_id = donor['donorID']

            # Check eligibility (90-day rule)
            eligibility = execute_query("""
                SELECT
                    lastDonationDate,
                    CASE
                        WHEN lastDonationDate IS NULL THEN 1
                        WHEN DATEDIFF(DAY, lastDonationDate, GETDATE()) >= 90 THEN 1
                        ELSE 0
                    END AS IsEligible,
                    CASE
                        WHEN lastDonationDate IS NULL THEN 'Eligible - First time donation'
                        WHEN DATEDIFF(DAY, lastDonationDate, GETDATE()) >= 90 THEN 'Eligible for donation'
                        ELSE CAST(90 - DATEDIFF(DAY, lastDonationDate, GETDATE()) AS VARCHAR) + ' days remaining'
                    END AS StatusMessage
                FROM Donor
                WHERE donorID = ?
            """, (donor_id,))

            if eligibility and eligibility[0]['IsEligible'] == 1:
                # Eligible - redirect to donation form
                return redirect(url_for('add_donation', donor_id=donor_id))
            else:
                status_msg = eligibility[0]['StatusMessage'] if eligibility else 'Unknown eligibility status'
                flash(f'❌ Not eligible for donation: {status_msg}', 'warning')
                return render_template('direct_donation.html',
                                       donor=donor,
                                       status=status_msg)

        except Exception as e:
            flash(f'Error: {str(e)}', 'danger')
            return render_template('direct_donation.html')

    # GET request - show email input form
    return render_template('direct_donation.html')


# ---------------------------------------------------------
# HOSPITAL REQUESTS (keeping existing code)
# ---------------------------------------------------------

@app.route('/requests')
@login_required
def requests_list():
    """Blood requests list"""
    try:
        requests_data = execute_query("""
            SELECT br.bloodRequestID, h.hospitalName, p.patientName, bg.groupName AS BloodRequired,
                   br.requiredUnits, br.urgency, br.requestStatus, br.requestDate
            FROM BloodRequest br
            JOIN Hospital h ON br.hospitalID = h.hospitalID
            JOIN Patient p ON br.patientID = p.patientID
            JOIN BloodGroup bg ON br.bgID_Requested = bg.bgID
            ORDER BY CASE WHEN br.requestStatus = 'pending' THEN 0 ELSE 1 END, br.requestDate DESC
        """) or []
        return render_template('requests.html', requests=requests_data)
    except Exception as e:
        flash(f'Error loading requests: {str(e)}', 'danger')
        return render_template('requests.html', requests=[])


@app.route('/new_request', methods=['GET', 'POST'])
@login_required
def new_request():
    """Create new blood request"""
    if request.method == 'POST':
        try:
            hospital = request.form['hospital']
            doctor = request.form['doctor']
            patient = request.form['patient']
            bg = request.form['bg']
            units = request.form['units']
            urgency = request.form['urgency']

            result = execute_query("""
                INSERT INTO BloodRequest (hospitalID, doctorID, patientID, bgID_Requested, requiredUnits,
                                          urgency, requestStatus, requestDate)
                VALUES (?, ?, ?, ?, ?, ?, 'pending', GETDATE())
            """, (hospital, doctor, patient, bg, units, urgency), fetch=False)

            if result:
                flash('Blood Request Submitted!', 'success')
                return redirect(url_for('requests_list'))
            else:
                flash('Failed to submit request!', 'danger')

        except Exception as e:
            flash(f'Error: {str(e)}', 'danger')

    try:
        hospitals = execute_query("SELECT hospitalID, hospitalName FROM Hospital") or []
        doctors = execute_query("SELECT doctorID, doctorName FROM Doctor") or []
        patients = execute_query("SELECT patientID, patientName FROM Patient") or []
        bgs = execute_query("SELECT * FROM BloodGroup") or []

        return render_template('new_request.html',
                               hospitals=hospitals,
                               doctors=doctors,
                               patients=patients,
                               bgs=bgs)
    except Exception as e:
        flash(f'Error loading form data: {str(e)}', 'danger')
        return render_template('new_request.html',
                               hospitals=[],
                               doctors=[],
                               patients=[],
                               bgs=[])


@app.route('/fulfill/<int:req_id>', methods=['GET', 'POST'])
@login_required
def fulfill_request(req_id):
    """Fulfill blood request"""
    try:
        req_data = execute_query("""
            SELECT br.*, bg.groupName as BGName
            FROM BloodRequest br
            JOIN BloodGroup bg ON br.bgID_Requested = bg.bgID
            WHERE bloodRequestID = ?
        """, (req_id,))

        if not req_data:
            flash('Request not found!', 'danger')
            return redirect(url_for('requests_list'))

        current_request = req_data[0]

        if request.method == 'POST':
            unit_id = request.form['unit_id']
            staff_id = request.form['staff_id']

            conn = get_db_connection()
            if not conn:
                flash('Database connection failed!', 'danger')
                return redirect(url_for('requests_list'))

            try:
                cursor = conn.cursor()
                cursor.execute("BEGIN TRANSACTION")
                cursor.execute("UPDATE BloodUnit SET status = 'used' WHERE bloodUnitID = ?", (unit_id,))
                cursor.execute("""
                    INSERT INTO DeliveryRecord (bloodRequestID, bloodUnitID, deliveryDate, deliveredByStaffID, bloodCondition)
                    VALUES (?, ?, GETDATE(), ?, 'cold chain maintained')
                """, (req_id, unit_id, staff_id))
                cursor.execute("UPDATE BloodRequest SET requestStatus = 'delivered' WHERE bloodRequestID = ?",
                               (req_id,))
                conn.commit()

                flash('Order Fulfilled Successfully!', 'success')
                return redirect(url_for('requests_list'))

            except Exception as e:
                conn.rollback()
                flash(f'Transaction Failed: {str(e)}', 'danger')
            finally:
                if conn:
                    conn.close()

        matches = execute_query("""
            SELECT TOP 5 bu.bloodUnitID, bu.expiryDate,
                   c.bloodCenterName,
                   DATEDIFF(day, GETDATE(), bu.expiryDate) as DaysLeft
            FROM BloodUnit bu
            JOIN BloodGroup bg ON bu.bgID = bg.bgID
            JOIN BloodBankCenter c ON bu.centerID = c.centerID
            WHERE bg.groupName = ?
              AND bu.status = 'stored'
              AND bu.expiryDate > GETDATE()
            ORDER BY bu.expiryDate ASC
        """, (current_request['BGName'],)) or []

        staff_list = execute_query("SELECT staffID, staffName FROM Staff") or []

        return render_template('fulfill.html',
                               req=current_request,
                               matches=matches,
                               staff_list=staff_list)

    except Exception as e:
        flash(f'Error processing request: {str(e)}', 'danger')
        return redirect(url_for('requests_list'))


# ---------------------------------------------------------
# ANALYTICS
# ---------------------------------------------------------

@app.route('/analytics')
@login_required
def analytics():
    """System analytics"""
    try:
        demand = execute_query("""
            SELECT TOP 5 bg.groupName, COUNT(br.bloodRequestID) AS TotalRequests
            FROM BloodRequest br
            JOIN BloodGroup bg ON br.bgID_Requested = bg.bgID
            GROUP BY bg.groupName
            ORDER BY TotalRequests DESC
        """) or []

        donors = execute_query("""
            SELECT TOP 10 d.name, d.contactNo, COUNT(do.donationID) AS TotalDonations
            FROM Donor d
            JOIN Donation do ON d.donorID = do.donorID
            GROUP BY d.name, d.contactNo
            ORDER BY TotalDonations DESC
        """) or []

        hospitals = execute_query("""
            SELECT TOP 5 h.hospitalName, h.city, COUNT(br.bloodRequestID) AS TotalOrders
            FROM BloodRequest br
            JOIN Hospital h ON br.hospitalID = h.hospitalID
            GROUP BY h.hospitalName, h.city
            ORDER BY TotalOrders DESC
        """) or []

        return render_template('analytics.html',
                               demand=demand,
                               donors=donors,
                               hospitals=hospitals)

    except Exception as e:
        flash(f'Error loading analytics: {str(e)}', 'danger')
        return render_template('analytics.html',
                               demand=[],
                               donors=[],
                               hospitals=[])


@app.route('/add_hospital', methods=['GET', 'POST'])
@login_required
@role_required('admin')
def add_hospital():
    """Admin: Add a new hospital"""
    if request.method == 'POST':
        try:
            name = request.form['name']
            address = request.form['address']
            city = request.form['city']
            contact = request.form['contact']
            email = request.form['email']

            execute_query("""
                          INSERT INTO Hospital (hospitalName, hospitalAddress, city, contactNumber, emailAddress)
                          VALUES (?, ?, ?, ?, ?)
                          """, (name, address, city, contact, email), fetch=False)

            flash(f'✅ Hospital "{name}" added successfully!', 'success')
            return redirect(url_for('dashboard'))

        except Exception as e:
            flash(f'Error adding hospital: {str(e)}', 'danger')

    return render_template('add_hospital.html')


@app.route('/add_doctor', methods=['GET', 'POST'])
@login_required
@role_required('admin')
def add_doctor():
    """Admin: Add a new doctor and create login"""
    if request.method == 'POST':
        conn = get_db_connection()
        if not conn:
            flash('Database connection error', 'danger')
            return redirect(url_for('dashboard'))

        try:
            name = request.form['name']
            hospital_id = request.form['hospital_id']
            specialization = request.form['specialization']
            contact = request.form['contact']
            email = request.form['email']

            # Default password for new users
            default_pass = 'Password@123'

            cursor = conn.cursor()

            # 1. Insert into Doctor table
            cursor.execute("""
                           INSERT INTO Doctor (hospitalID, doctorName, specialization, contactNumber, emailAddress)
                               OUTPUT INSERTED.doctorID
                           VALUES (?, ?, ?, ?, ?)
                           """, (hospital_id, name, specialization, contact, email))

            new_doctor_id = cursor.fetchone()[0]

            # 2. Insert into UserLogin table (Auto-create account)
            # Using simple SHA2_256 hash logic as per your SQL schema patterns
            cursor.execute("""
                           INSERT INTO UserLogin (doctorID, username, passwordHash, plainPassword, userRole, isActive)
                           VALUES (?, ?, CONVERT(VARCHAR (255), HASHBYTES('SHA2_256', ?)), ?, 'doctor', 1)
                           """, (new_doctor_id, email, default_pass, default_pass))

            conn.commit()
            cursor.close()
            conn.close()

            flash(f'✅ Doctor "{name}" registered! Login: {email} / {default_pass}', 'success')
            return redirect(url_for('dashboard'))

        except Exception as e:
            if conn:
                conn.rollback()
            flash(f'Error adding doctor: {str(e)}', 'danger')
            print(e)

    # GET: Fetch hospitals for dropdown
    hospitals = execute_query("SELECT hospitalID, hospitalName, city FROM Hospital") or []
    return render_template('add_doctor.html', hospitals=hospitals)


@app.route('/add_staff', methods=['GET', 'POST'])
@login_required
@role_required('admin')
def add_staff():
    """Admin: Add new staff member and create login"""
    if request.method == 'POST':
        conn = get_db_connection()
        if not conn:
            flash('Database connection error', 'danger')
            return redirect(url_for('dashboard'))

        try:
            name = request.form['name']
            center_id = request.form['center_id']
            role = request.form['role']
            contact = request.form['contact']
            email = request.form['email']

            default_pass = 'Password@123'

            cursor = conn.cursor()

            # 1. Insert into Staff table
            cursor.execute("""
                           INSERT INTO Staff (centerID, staffName, staffRole, staffContactNumber, staffEmailAddress)
                               OUTPUT INSERTED.staffID
                           VALUES (?, ?, ?, ?, ?)
                           """, (center_id, name, role, contact, email))

            new_staff_id = cursor.fetchone()[0]

            # 2. Insert into UserLogin table
            cursor.execute("""
                           INSERT INTO UserLogin (staffID, username, passwordHash, plainPassword, userRole, isActive)
                           VALUES (?, ?, CONVERT(VARCHAR (255), HASHBYTES('SHA2_256', ?)), ?, 'staff', 1)
                           """, (new_staff_id, email, default_pass, default_pass))

            conn.commit()
            cursor.close()
            conn.close()

            flash(f'✅ Staff "{name}" registered! Login: {email} / {default_pass}', 'success')
            return redirect(url_for('dashboard'))

        except Exception as e:
            if conn:
                conn.rollback()
            flash(f'Error adding staff: {str(e)}', 'danger')

    # GET: Fetch centers for dropdown
    centers = execute_query("SELECT centerID, bloodCenterName, city FROM BloodBankCenter") or []
    return render_template('add_staff.html', centers=centers)
# ---------------------------------------------------------
# ERROR HANDLERS
# ---------------------------------------------------------

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404


@app.errorhandler(500)
def internal_server_error(e):
    return render_template('500.html'), 500


# ---------------------------------------------------------
# RUN APPLICATION
# ---------------------------------------------------------
if __name__ == '__main__':
    print("=" * 60)
    print("🩸 BLOOD BANK MANAGEMENT SYSTEM")
    print("=" * 60)
    print("🌐 Server URL: http://127.0.0.1:5000")
    print("🔑 Login Credentials:")
    print("   Admin: superadmin@bloodbank.org / Admin@123")
    print("=" * 60)
    print("🚀 Starting application...")

    try:
        conn = get_db_connection()
        if conn:
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            cursor.fetchone()
            cursor.close()
            conn.close()
            print("✅ Database connection test successful!")
    except Exception as e:
        print(f"⚠️ Database warning: {e}")

    app.run(debug=True, port=5000)